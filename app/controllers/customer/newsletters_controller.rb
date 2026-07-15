class Customer::NewslettersController < ApplicationController
  def index
    ActsAsTenant.without_tenant do
      @customers = Customer.where(user_id: Current.user.id).includes(:account)
      subscribed_customer_ids = @customers.select(&:subscribed_to_newsletter?).map(&:id)

      @newsletters = []
      if subscribed_customer_ids.any?
        # This is a bit tricky with multi-tenancy. We want newsletters from accounts where they are subscribed.
        # Newsletter model also acts_as_tenant :account.
        subscribed_account_ids = @customers.select(&:subscribed_to_newsletter?).map(&:account_id)
        @newsletters = Newsletter.unscoped.where(account_id: subscribed_account_ids)
                                 .where.not(sent_at: nil)
                                 .order(sent_at: :desc)
                                 .limit(10)
      end
    end
  end

  def show
    ActsAsTenant.without_tenant do
      @newsletter = Newsletter.unscoped.find(params[:id])
      @customer = Customer.find_by(account_id: @newsletter.account_id, user_id: Current.user.id)

      if @customer.nil? || !@customer.subscribed_to_newsletter? || (@newsletter.sent_at.present? && @newsletter.sent_at < @customer.subscribed_at)
        redirect_to customer_newsletters_path, alert: "You are not authorized to view this newsletter."
      end
    end
  end

  def subscribe
    ActsAsTenant.without_tenant do
      account_id = params[:account_id] || Current.account&.id
      @customer = Customer.find_by(account_id: account_id, user_id: Current.user.id)

      if @customer&.update(subscribed_to_newsletter: true)
        redirect_to customer_newsletters_path, notice: "You have successfully subscribed to the newsletter."
      else
        redirect_to customer_newsletters_path, alert: "There was an error subscribing you to the newsletter."
      end
    end
  end

  def unsubscribe
    ActsAsTenant.without_tenant do
      @customer = Customer.find(params[:id])

      if @customer.user_id == Current.user.id && @customer.update(subscribed_to_newsletter: false)
        redirect_to customer_newsletters_path, notice: "You have unsubscribed from #{@customer.account.name} newsletter."
      else
        redirect_to customer_newsletters_path, alert: "There was an error unsubscribing you."
      end
    end
  end

  private
end
