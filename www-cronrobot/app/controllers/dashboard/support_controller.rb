
class Dashboard::SupportController < DashboardController
  def index
  end

  def contact
    SupportMailer.with(
      attributes: params,
      email_to: Rails.application.credentials.dig(:mails, :support)
    ).contact.deliver_now

    flash[:success] = "Contact support sent successfully!"
    redirect_back fallback_location: root_path
  end
end
