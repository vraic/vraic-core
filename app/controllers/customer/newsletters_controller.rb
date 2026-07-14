class Customer::NewslettersController < ApplicationController
  before_action :set_customer

  def index
    if @customer.subscribed_to_newsletter?
      @newsletters = Newsletter.where("sent_at >= ?", @customer.subscribed_at).order(sent_at: :desc)
    else
      @newsletters = []
    end
  end

  def show
    @newsletter = Newsletter.find(params[:id])
    if !@customer.subscribed_to_newsletter? || (@newsletter.sent_at.present? && @newsletter.sent_at < @customer.subscribed_at)
      redirect_to customer_newsletters_path, alert: "You are not authorized to view this newsletter."
    end
  end

  def subscribe
    if @customer.update(subscribed_to_newsletter: true)
      redirect_to customer_newsletters_path, notice: "You have successfully subscribed to our newsletter."
    else
      redirect_to customer_newsletters_path, alert: "There was an error subscribing you to the newsletter."
    end
  end

  private

  def set_customer
    @customer = Current.account.customers.find_by(user_id: Current.user.id)
    unless @customer
      redirect_to dashboard_path, alert: "You must be a customer of this store to access newsletters."
    end
  end
end
