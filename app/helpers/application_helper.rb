module ApplicationHelper
  def pagy_tailwind_nav(pagy)
    pagy.series_nav("tailwind")
  end
  def enum_options_for_select(instance, enum)
    options_for_select(enum_collection(instance, enum), instance.send(enum))
  end

  def enum_collection(instance, enum)
    instance.class.send(enum.to_s.pluralize).keys.to_a.map { |key| [ key.titleize, key ] }
  end

  def nav_item_active?(item)
    case item
    when :dashboard
      controller_name == "pages" && [ "home", "dashboard" ].include?(action_name)
    when :customers
      controller_name == "customers"
    when :suppliers
      controller_name == "suppliers" || controller_name == "supplier_requests"
    when :tasks
      controller_name == "tasks"
    when :inventory
      [ "inventory_items", "locations", "inventory_groups", "inventory_levels" ].include?(controller_name)
    when :orders
      controller_name == "orders"
    when :reports
      controller_name == "reports"
    when :settings
      [ "accounts", "account_users", "users", "settings" ].include?(controller_name)
    else
      false
    end
  end

  def nav_link_classes(item_key, extra_classes = nil)
    active = nav_item_active?(item_key)
    base_classes = [ "group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold", extra_classes ].compact.join(" ")

    if active
      "#{base_classes} bg-gray-50 text-indigo-600 dark:bg-white/5 dark:text-white"
    else
      "#{base_classes} text-gray-700 hover:text-indigo-600 hover:bg-gray-50 dark:text-gray-400 dark:hover:text-white dark:hover:bg-white/5"
    end
  end

  def nav_icon_classes(item_key, extra_classes = nil)
    active = nav_item_active?(item_key)
    base_classes = [ "size-6 shrink-0", extra_classes ].compact.join(" ")

    if active
      "#{base_classes} text-indigo-600 dark:text-white"
    else
      "#{base_classes} text-gray-400 group-hover:text-indigo-600 dark:group-hover:text-white"
    end
  end

  def label_class(extra_classes = nil)
    [ "block text-sm font-medium leading-6 text-gray-900 dark:text-white", extra_classes ].compact.join(" ")
  end

  def input_class(has_error = false, extra_classes = nil)
    base = "block w-full rounded-md border-0 py-1.5 px-3 h-9 text-gray-900 shadow-sm ring-1 ring-inset placeholder:text-gray-400 focus:ring-2 focus:ring-inset sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-white"
    color_classes = if has_error
      "ring-red-300 focus:ring-red-600 dark:ring-red-500"
    else
      "ring-gray-300 focus:ring-indigo-600 dark:ring-gray-700"
    end
    [ base, color_classes, extra_classes ].compact.join(" ")
  end

  def primary_button_class(extra_classes = nil)
    [ "rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 cursor-pointer", extra_classes ].compact.join(" ")
  end

  def secondary_button_class(extra_classes = nil)
    [ "rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 dark:bg-gray-700 dark:text-white dark:ring-gray-600 dark:hover:bg-gray-600 cursor-pointer", extra_classes ].compact.join(" ")
  end

  def danger_button_class(extra_classes = nil)
    [ "rounded-md bg-red-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-600 cursor-pointer", extra_classes ].compact.join(" ")
  end

  def table_container_class(extra_classes = nil)
    [ "bg-white dark:bg-gray-800 rounded-lg shadow-sm overflow-hidden border border-gray-200 dark:border-gray-700", extra_classes ].compact.join(" ")
  end

  def table_class(extra_classes = nil)
    [ "min-w-full divide-y divide-gray-200 dark:divide-gray-700", extra_classes ].compact.join(" ")
  end

  def thead_class(extra_classes = nil)
    [ "bg-gray-50 dark:bg-gray-900", extra_classes ].compact.join(" ")
  end

  def th_class(extra_classes = nil)
    [ "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider", extra_classes ].compact.join(" ")
  end

  def tbody_class(extra_classes = nil)
    [ "divide-y divide-gray-200 dark:divide-gray-700", extra_classes ].compact.join(" ")
  end

  def tr_class(extra_classes = nil)
    [ extra_classes ].compact.join(" ")
  end

  def td_class(extra_classes = nil)
    [ "px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white", extra_classes ].compact.join(" ")
  end

  def help_text_class(extra_classes = nil)
    [ "mt-2 text-sm text-gray-500 dark:text-gray-400", extra_classes ].compact.join(" ")
  end
end
