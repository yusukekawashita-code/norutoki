class MyPageController < ApplicationController
  before_action :require_login

  def show
    @usual_routes = current_user.usual_routes
  end
end
