class SupplierRequestsController < ApplicationController
  before_action :require_account!
  before_action :set_supplier_request, only: %i[ update destroy ]

  def index
    @supplier_requests = policy_scope(SupplierRequest)
  end

  def new
    @supplier_request = SupplierRequest.new
    authorize @supplier_request
  end

  def create
    @supplier_request = SupplierRequest.new(supplier_request_params)
    @supplier_request.sender_account = ActsAsTenant.current_tenant
    authorize @supplier_request

    if @supplier_request.save
      redirect_to supplier_requests_path, notice: "Supplier request was successfully sent."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @supplier_request
    if @supplier_request.update(status: params[:status])
      redirect_to supplier_requests_path, notice: "Supplier request was #{params[:status]}."
    else
      redirect_to supplier_requests_path, alert: "Could not update supplier request."
    end
  end

  def destroy
    authorize @supplier_request
    @supplier_request.destroy!
    redirect_to supplier_requests_path, notice: "Supplier request was cancelled/removed.", status: :see_other
  end

  private

  def set_supplier_request
    @supplier_request = SupplierRequest.find(params[:id])
  end

  def supplier_request_params
    params.require(:supplier_request).permit(:receiver_account_id)
  end
end
