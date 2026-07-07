class CustomersController < ApplicationController
  before_action :require_account!
  before_action :set_customer, only: %i[ show edit update destroy really_destroy ]

  # GET /customers or /customers.json
  def index
    @customers = policy_scope(Customer)
  end

  # GET /customers/1 or /customers/1.json
  def show
    authorize @customer
  end

  # GET /customers/new
  def new
    @customer = Customer.new
    authorize @customer
  end

  # GET /customers/1/edit
  def edit
    authorize @customer
  end

  # POST /customers or /customers.json
  def create
    @customer = Customer.new(customer_params)
    authorize @customer

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: "Customer was successfully created." }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @customer.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /customers/1 or /customers/1.json
  def update
    authorize @customer
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: "Customer was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @customer.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /customers/1 or /customers/1.json
  def destroy
    authorize @customer
    @customer.destroy!

    respond_to do |format|
      format.html { redirect_to customers_path, notice: "Customer was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def really_destroy
    authorize @customer
    @customer.destroy_fully!

    respond_to do |format|
      format.html { redirect_to customers_path, notice: "Customer was permanently deleted.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def customer_params
      attributes = [ :name, :email_address, :phone ]
      attributes += [ :account_id ] if Current.user.admin?
      params.require(:customer).permit(attributes)
    end
end
