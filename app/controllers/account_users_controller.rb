class AccountUsersController < ApplicationController
  before_action :set_account_from_params
  around_action :scope_to_account
  before_action :set_account_user, only: %i[ show edit update destroy ]

  # GET /accounts/:account_id/account_users or /accounts/:account_id/account_users.json
  def index
    authorize AccountUser
    @pagy, @account_users = pagy(AccountUser.all)
  end

  # GET /account_users/1 or /account_users/1.json
  def show
    authorize @account_user
  end

  # GET /accounts/:account_id/account_users/new
  def new
    @account_user = AccountUser.new(account: @account)
    authorize @account_user
  end

  # GET /account_users/1/edit
  def edit
    authorize @account_user
  end

  # POST /accounts/:account_id/account_users or /accounts/:account_id/account_users.json
  def create
    email = params[:email_address].to_s.strip.downcase

    user = User.find_by(email_address: email)
    if user.nil?
      user = User.new(email_address: email)
      user.name = email.split("@").first.to_s.humanize
      user.password = user.password_confirmation = SecureRandom.alphanumeric(32)
      user.prefers_email_login = true
      user.save!
    end

    @account_user = AccountUser.new(account_user_params)
    @account_user.user = user
    @account_user.account = @account

    authorize @account_user

    respond_to do |format|
      if @account_user.save
        user.password = user.password_confirmation = nil
        UserMailer.account_invitation(user, @account).deliver_later
        format.html { redirect_to @account, notice: "Account user was successfully created." }
        format.json { render :show, status: :created, location: @account_user }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @account_user.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /account_users/1 or /account_users/1.json
  def update
    authorize @account_user
    respond_to do |format|
      if @account_user.update(account_user_params)
        format.html { redirect_to @account_user.account, notice: "Account user was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @account_user }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @account_user.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /account_users/1 or /account_users/1.json
  def destroy
    authorize @account_user
    account = @account_user.account
    @account_user.destroy!

    respond_to do |format|
      format.html { redirect_to account, notice: "Account user was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_account_from_params
      if params[:account_id]
        @account = Account.find(params[:account_id])
      elsif params[:id]
        @account_user = AccountUser.unscoped.find(params[:id])
        @account = @account_user.account
      end
    end

    def scope_to_account
      ActsAsTenant.with_tenant(@account) do
        yield
      end
    end

    def set_account_user
      @account_user = AccountUser.find(params[:id])
    end

    def account_user_params
      params.require(:account_user).permit(:user_role)
    end
end
