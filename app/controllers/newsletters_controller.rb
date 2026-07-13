class NewslettersController < ApplicationController
  before_action :set_newsletter, only: %i[ show edit update destroy deliver ]

  def index
    @newsletters = Newsletter.all
    if params[:target].present?
      @newsletters = @newsletters.where(target: params[:target])
    end
  end

  def show
  end

  def new
    @newsletter = Newsletter.new
  end

  def edit
  end

  def create
    @newsletter = Newsletter.new(newsletter_params)

    if @newsletter.save
      redirect_to @newsletter, notice: "Newsletter was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @newsletter.update(newsletter_params)
      redirect_to @newsletter, notice: "Newsletter was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @newsletter.destroy
    redirect_to newsletters_url, notice: "Newsletter was successfully destroyed."
  end

  def deliver
    NewsletterDeliveryJob.perform_later(@newsletter)
    @newsletter.update(sent_at: Time.current)
    redirect_to @newsletter, notice: "Newsletter delivery has been started."
  end

  private

  def set_newsletter
    @newsletter = Newsletter.find(params[:id])
  end

  def newsletter_params
    params.require(:newsletter).permit(:subject, :content, :target)
  end
end
