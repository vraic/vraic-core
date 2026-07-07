namespace :db do
  desc "Clear the database and re-seed with dev data"
  task reseed: :environment do
    puts "Clearing database..."
    
    ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF;")
    [
      "order_items", "orders", "inventory_levels", "inventory_items",
      "locations", "inventory_group_suppliers", "inventory_group_customers",
      "inventory_groups", "supplier_prices", "supplier_requests",
      "suppliers", "customers", "account_users", "accounts",
      "sessions", "tasks", "users"
    ].each do |table_name|
      ActiveRecord::Base.connection.execute("DELETE FROM #{table_name}")
    end
    ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON;")

    puts "Seeding data..."

    # 1. Global Admin Account
    admin = User.create!(
      name: "Global Admin",
      email_address: "admin@example.com",
      password: "password",
      admin: true
    )
    puts "Created Global Admin: admin@example.com / password"

    # 2. Main Account (Account One)
    account_one = Account.create!(
      name: "Account One",
      address: "123 Farm Road, St Brelade, Jersey",
      owner_id: admin.id
    )
    
    account_one_admin = User.create!(
      name: "Account One Admin",
      email_address: "account-one@example.com",
      password: "password"
    )
    AccountUser.create!(account: account_one, user: account_one_admin, user_role: :admin)

    account_one_staff = User.create!(
      name: "Account One Staff",
      email_address: "account-one-staff@example.com",
      password: "password"
    )
    AccountUser.create!(account: account_one, user: account_one_staff, user_role: :standard)
    puts "Created Account One with admin (account-one@example.com) and staff (account-one-staff@example.com)"

    # 3. Suppliers
    suppliers = []
    3.times do |i|
      num = i + 1
      name = "Supplier #{num}"
      email = "supplier-#{num}@example.com"
      s_acc = Account.create!(
        name: name,
        address: "#{num} Supplier St, St Helier, Jersey",
        owner_id: admin.id
      )
      s_user = User.create!(
        name: "#{name} User",
        email_address: email,
        password: "password"
      )
      AccountUser.create!(account: s_acc, user: s_user, user_role: :admin)
      suppliers << s_acc
      puts "Created #{name}: #{email}"
    end

    # 4. Customer Account
    customer_account = Account.create!(
      name: "Customer One",
      address: "Customer Ave, St Peter, Jersey",
      owner_id: admin.id
    )
    customer_user = User.create!(
      name: "Customer User",
      email_address: "customer-one@example.com",
      password: "password"
    )
    AccountUser.create!(account: customer_account, user: customer_user, user_role: :admin)
    puts "Created Customer Account: customer-one@example.com"

    # 5. Establish Relationships via SupplierRequests
    
    # Supplier 1 and 2 supply Account One
    [suppliers[0], suppliers[1]].each do |s_acc|
      req = SupplierRequest.create!(sender_account: s_acc, receiver_account: account_one)
      req.approved!
    end
    
    # Account One supplies Supplier 3 and Customer One
    [suppliers[2], customer_account].each do |c_acc|
      req = SupplierRequest.create!(sender_account: account_one, receiver_account: c_acc)
      req.approved!
    end
    puts "Established bidirectional relationships via SupplierRequests"

    # 6. Inventory and Content for Account One
    ActsAsTenant.with_tenant(account_one) do
      group_data = {
        "Meat" => ["Ribeye Steak", "Chicken Breast", "Pork Chops", "Lamb Leg", "Bacon", "Sirloin", "Duck Breast", "Venison", "Sausages", "Burgers"],
        "Dairy" => ["Whole Milk", "Cheddar Cheese", "Butter", "Yogurt", "Cream", "Skimmed Milk", "Brie", "Goats Cheese", "Eggs", "Cottage Cheese"],
        "Fruit" => ["Braeburn Apple", "Banana", "Strawberries", "Blueberries", "Pear", "Raspberries", "Oranges", "Plums", "Cherries", "Grapes"],
        "Vegetables" => ["Carrots", "Potatoes", "Broccoli", "Spinach", "Onions", "Peas", "Corn", "Peppers", "Cucumber", "Lettuce"],
        "Bakery" => ["Sourdough Loaf", "Croissant", "Baguette", "Muffin", "Brownie", "White Loaf", "Bagel", "Scone", "Danish", "Pita"]
      }

      locations = [
        Location.create!(name: "Farm Shop"),
        Location.create!(name: "Cold Store"),
        Location.create!(name: "Roadside Stall")
      ]
      puts "Created 3 locations in Account One"

      # Fetch the customers that were created via SupplierRequest approval
      # Customer records are created in the sender's tenant.
      # When Account One supplies Supplier 3 and Customer One, Account One is the sender.
      # So Account One has Customer records for Supplier 3 and Customer One.
      
      regular_customers = [
        Customer.create!(name: "Regular Joe", email_address: "joe@example.com"),
        Customer.create!(name: "Frequent Flo", email_address: "flo@example.com")
      ]

      group_data.each do |group_name, item_names|
        ig = InventoryGroup.create!(name: group_name)
        item_names.each do |name|
          item = InventoryItem.create!(
            name: name,
            inventory_group: ig,
            price: Money.new(rand(500..3500))
          )
          
          locations.each do |loc|
            InventoryLevel.create!(
              inventory_item: item,
              location: loc,
              quantity: rand(10..100)
            )
          end
        end
      end
      puts "Created 5 inventory groups with 10 products each, stocked in all 3 locations"
      
      # Tasks
      Task.create!(
        title: "Check Cold Store temperature",
        description: "Ensure it stays below 4 degrees",
        responsible_user: account_one_admin,
        assigned_by: account_one_admin
      )
      
      Task.create!(
        title: "Restock Roadside Stall",
        description: "Potatoes and Apples are running low",
        responsible_user: account_one_staff,
        assigned_by: account_one_admin
      )
      puts "Created sample tasks"

      # Orders
      regular_customers.each do |customer|
        order = Order.new(
          customer: customer,
          user: account_one_staff,
          status: :complete,
          notes: "Sample seed order"
        )
        
        InventoryItem.all.sample(rand(2..4)).each do |item|
          order.order_items.build(
            inventory_item: item,
            location: locations.sample,
            quantity: rand(1..3),
            price: item.price
          )
        end
        order.save!
      end
      puts "Created sample orders"

      # Custom pricing for suppliers
      # Supplier 1 and 2 supply Account One, so Account One has Supplier records for them.
      [suppliers[0], suppliers[1]].each do |s_acc|
        supplier_rec = Supplier.find_by(supplier_account_id: s_acc.id)
        if supplier_rec
          InventoryItem.limit(5).each do |item|
            SupplierPrice.create!(
              supplier: supplier_rec,
              inventory_item: item,
              price: item.price * 0.8
            )
          end
        end
      end
      puts "Added custom supplier pricing from Supplier 1 and 2"
    end

    # 7. Suppliers' own inventory
    suppliers.each do |s_acc|
      ActsAsTenant.with_tenant(s_acc) do
        s_group = InventoryGroup.create!(name: "#{s_acc.name} Wholesale")
        loc = Location.create!(name: "Main Warehouse")
        ["Bulk Item A", "Bulk Item B", "Bulk Item C", "Special Resource"].each do |name|
          item = InventoryItem.create!(
            name: "#{s_acc.name} #{name}",
            inventory_group: s_group,
            price: Money.new(rand(1000..5000))
          )
          InventoryLevel.create!(inventory_item: item, location: loc, quantity: 500)
        end
        
        # Grant visibility to Account One (if it's a customer of this supplier)
        customer_rec = Customer.find_by(customer_account_id: account_one.id)
        if customer_rec
          InventoryGroupCustomer.create!(inventory_group: s_group, customer: customer_rec)
        end
        puts "Created #{s_acc.name}'s inventory and shared it with Account One"
      end
    end

    # 8. Pending Request for realism
    pending_acc = Account.create!(name: "Future Partner", owner_id: admin.id)
    SupplierRequest.create!(sender_account: pending_acc, receiver_account: account_one)
    puts "Added a pending Supplier Request from Future Partner"

    puts "Done! Seeded dev environment."
  end
end
