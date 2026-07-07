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
      if AccountUser.unscoped.exists?(user: Current.user, account_id: account_id)
        account = Account.find(account_id)
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
