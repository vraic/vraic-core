class ManagedAccountsController < ApplicationController
  def update
    account_id = params[:account_id]

    if Current.user.admin?
      if account_id.present?
        account = Account.find(account_id)
        session[:managed_account_id] = account.id
        flash[:notice] = "Now managing #{account.name}"
      else
        session.delete(:managed_account_id)
        flash[:notice] = "Switched to Global view"
      end
    elsif account_id.present?
      account = Account.find(account_id)

      # Check direct access
      has_access = AccountUser.unscoped.exists?(user: Current.user, account_id: account.id)

      # Check B2B access through any of the user's accounts
      if !has_access
        user_account_ids = Current.user.account_users.pluck(:account_id)
        if Customer.unscoped.where(account: account, customer_account_id: user_account_ids).exists?
          # Ensure they have an AccountUser in the target account so set_tenant works
          ActsAsTenant.with_tenant(account) do
            AccountUser.where(user: Current.user).first_or_create!(user_role: :customer)
          end
          has_access = true
        end
      end

      if has_access
        session[:managed_account_id] = account.id
        flash[:notice] = "Switched to #{account.name}"
      else
        flash[:alert] = "You do not have access to that account."
      end
    else
      flash[:alert] = "Please select an account."
    end

    redirect_back fallback_location: root_path
  end

  def destroy
    session.delete(:managed_account_id)
    flash[:notice] = "Stopped managing account"
    redirect_back fallback_location: root_path
  end
end
