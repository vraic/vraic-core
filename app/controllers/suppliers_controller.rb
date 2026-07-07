class SuppliersController < ApplicationController
  before_action :require_account!
  before_action :set_supplier, only: %i[ show edit update destroy inventory ]

  def index
    @pagy, @suppliers = pagy(policy_scope(Supplier))
  end

  def show
    authorize @supplier
  end

  def new
    @supplier = Supplier.new
    authorize @supplier
  end

  def edit
    authorize @supplier
  end

  def create
    @supplier = Supplier.new(supplier_params)
    authorize @supplier

    respond_to do |format|
      if @supplier.save
        format.html { redirect_to @supplier, notice: "Supplier was successfully created." }
        format.json { render :show, status: :created, location: @supplier }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @supplier.errors, status: :unprocessable_content }
      end
    end
  end

  def update
    authorize @supplier
    respond_to do |format|
      if @supplier.update(supplier_params)
        format.html { redirect_to @supplier, notice: "Supplier was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @supplier }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @supplier.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    authorize @supplier
    @supplier.destroy!
    respond_to do |format|
      format.html { redirect_to suppliers_path, notice: "Supplier was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def inventory
    authorize @supplier
    @inventory_items = @supplier.inventory_items
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    attributes = [ :name, :email_address, :phone ]
    attributes += [ :account_id ] if Current.user.admin?
    params.require(:supplier).permit(attributes)
  end
end
