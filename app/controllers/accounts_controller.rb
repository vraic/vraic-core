class AccountsController < ApplicationController
  before_action :set_account, only: %i[ show edit update destroy ]

  # GET /accounts or /accounts.json
  def index
    @accounts = policy_scope(Account)
  end

  # GET /accounts/1 or /accounts/1.json
  def show
    authorize @account
  end

  # GET /accounts/new
  def new
    @account = Account.new(owner_id: Current.user.id)
    authorize @account
  end

  # GET /accounts/1/edit
  def edit
    authorize @account
  end

  # POST /accounts or /accounts.json
  def create
    @account = Account.new(account_params)
    @account.owner_id ||= Current.user&.id
    authorize @account

    respond_to do |format|
      if @account.save
        # Create AccountUser for the owner
        if @account.owner_id
          AccountUser.unscoped.where(account_id: @account.id, user_id: @account.owner_id).first_or_create(user_role: :admin)
        end

        # Also make the creator an admin if different from owner
        if Current.user&.id && Current.user.id != @account.owner_id.to_i
          AccountUser.unscoped.where(account_id: @account.id, user_id: Current.user.id).first_or_create(user_role: :admin)
        end

        session[:managed_account_id] ||= @account.id

        if Current.user&.admin?
          format.html { redirect_to @account, notice: "Account was successfully created." }
        else
          format.html { redirect_to dashboard_path, notice: "Account was successfully created." }
        end
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @account.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /accounts/1 or /accounts/1.json
  def update
    authorize @account
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to @account, notice: "Account was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @account.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /accounts/1 or /accounts/1.json
  def destroy
    authorize @account
    @account.destroy!

    respond_to do |format|
      format.html { redirect_to accounts_path, notice: "Account was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.require(:account).permit(:name, :address, :owner_id)
    end
end
