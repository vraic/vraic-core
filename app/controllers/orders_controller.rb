class OrdersController < ApplicationController
  before_action :require_account!
  before_action :set_order, only: %i[ show edit update destroy awaiting_collection complete ]

  # GET /orders or /orders.json
  def index
    @query = params[:query]
    scope = policy_scope(Order).order(created_at: :desc)

    if params[:filter] == "today"
      scope = scope.where(created_at: Time.current.all_day)
    end

    if @query.present?
      clean_query = @query.delete("#").strip

      # Since name and email are encrypted, search_cop (LIKE) won't work. We handle exact match here.
      # We search in the current scope's tenant if possible, or unscoped if admin
      customer_ids = if Current.account
        Current.account.customers.where(name: clean_query).or(Current.account.customers.where(email_address: clean_query)).pluck(:id)
      else
        Customer.unscoped.where(name: clean_query).or(Customer.unscoped.where(email_address: clean_query)).pluck(:id)
      end

      begin
        decoded_id = Order.decode_prefix_id(clean_query)
      rescue StandardError
        decoded_id = nil
      end

      if decoded_id
        scope = scope.where(id: decoded_id)
      elsif clean_query.match?(/^\d{3}[A-Z]{3}$/)
        scope = scope.where(number: clean_query)
      elsif customer_ids.any?
        scope = scope.where(customer_id: customer_ids)
      else
        if @query.match?(/^\d+(\.\d{2})?$/)
          cents = (@query.to_f * 100).to_i
          scope = scope.search("#{@query} OR total_amount_cents: #{cents}")
        else
          scope = scope.search(@query)
        end
      end
    end

    @pagy, @orders = pagy(scope)
  end

  def awaiting_collection
    authorize @order, :update?
    @order.awaiting_collection!
    redirect_to @order, notice: "Order is now awaiting collection."
  end

  def complete
    authorize @order, :update?
    @order.complete!
    redirect_to @order, notice: "Order has been completed."
  end

  # GET /orders/1 or /orders/1.json
  def show
    authorize @order
  end

  # GET /orders/new
  def new
    @order = Order.new
    @order.order_items.build
    authorize @order
  end

  # GET /orders/1/edit
  def edit
    authorize @order
  end

  # POST /orders or /orders.json
  def create
    @order = Order.new(order_params)
    @order.account = Current.account
    @order.user = Current.user if staff?

    if Current.user&.admin? && session[:managed_account_id].present?
      @order.user = Current.account.owner
    end

    if customer?
      @order.customer = Customer.find_by(user: Current.user, account: Current.account)

      # B2B Fallback: if no personal record, use the one linked to any of the user's accounts
      if @order.customer.nil?
        user_account_ids = AccountUser.unscoped.where(user: Current.user).pluck(:account_id)
        @order.customer = Customer.find_by(account: Current.account, customer_account_id: user_account_ids)
      end
    end

    authorize @order

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        @order.order_items.build if @order.order_items.empty?
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @order.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /orders/1 or /orders/1.json
  def update
    authorize @order
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: "Order was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @order.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /orders/1 or /orders/1.json
  def destroy
    authorize @order
    @order.destroy!

    respond_to do |format|
      format.html { redirect_to orders_path, notice: "Order was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def order_params
      permitted_attributes = [ :customer_id, :notes, :status,
                               order_items_attributes: [ :id, :inventory_item_id, :location_id, :quantity, :price, :_destroy ] ]

      params.require(:order).permit(permitted_attributes)
    end
end
