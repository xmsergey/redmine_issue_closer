class IssuecloserController < AdminController
  unloadable

  include IssuecloserHelper

  def index
    gather_issues
  end

  def update
    update_status

    redirect_to action: :index, params: params.slice(:settings)
  end

end
