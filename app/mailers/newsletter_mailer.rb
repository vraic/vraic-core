class NewsletterMailer < ApplicationMailer
  has_history user: -> { params[:recipient] }, extra: { newsletter_id: -> { params[:newsletter].id } }

  def newsletter_email
    @newsletter = params[:newsletter]
    @recipient = params[:recipient]

    mail(to: @recipient.email_address, subject: @newsletter.subject)
  end
end
