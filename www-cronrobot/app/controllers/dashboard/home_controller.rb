class Dashboard::HomeController < DashboardController

  def index

    redirect_to controller: :schedulers

  end

end