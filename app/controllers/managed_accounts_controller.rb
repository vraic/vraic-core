class ManagedAccountsController < ApplicationController
  def update
    if Current.user.admin?
      if params[:account_id].present?
        account = Account.find(params[:account_id])
        session[:managed_account_id] = account.id
        flash[:notice] = "Now managing #{account.name}"
      else
        session.delete(:managed_account_id)
        flash[:notice] = "Switched to Global view"
      end
    else
      flash[:alert] = "Not authorized"
    end
    redirect_back fallback_location: root_path
  end

  def destroy
    session.delete(:managed_account_id)
    flash[:notice] = "Stopped managing account"
    redirect_back fallback_location: root_path
  end
end
