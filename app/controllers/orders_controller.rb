class OrdersController < ApplicationController
  before_action :require_account!
  before_action :set_order, only: %i[ show edit update destroy awaiting_collection complete ]

  # GET /orders or /orders.json
  def index
    @pagy, @orders = pagy(policy_scope(Order).order(created_at: :desc))
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

    if customer?
      @order.customer = Customer.find_by(user: Current.user, account: Current.account)
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

    def staff?
      Current.user.account_users.exists?(account: Current.account, user_role: [ :admin, :standard ])
    end

    def customer?
      Current.user.account_users.exists?(account: Current.account, user_role: :customer)
    end
end
