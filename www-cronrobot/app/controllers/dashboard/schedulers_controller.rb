class Dashboard::SchedulersController < DashboardController

  def index

    

  end

  def new

  end

  def create
    redirect_to action: :index
  end

end