class StoreMembershipsController < ApplicationController
  def create
    account = Account.find(params[:account_id])

    # Check if already a member
    if Current.user.accounts.include?(account)
      redirect_to dashboard_path, alert: "You are already a member of #{account.name}."
      return
    end

    # Create Customer record - this will also create AccountUser via callback
    Customer.create!(
      account: account,
      user: Current.user,
      name: Current.user.name,
      email_address: Current.user.email_address
    )

    session[:managed_account_id] = account.id
    redirect_to root_path, notice: "You have successfully joined #{account.name}."
  end
end
