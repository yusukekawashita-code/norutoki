class UsualRoutesController < ApplicationController
  before_action :require_login

  def index
    @usual_routes = current_user.usual_routes
  end

  def show
    @usual_route = current_user.usual_routes.find(params[:id])
  end

  def new
    @usual_route = current_user.usual_routes.build
  end

  def create
    @usual_route = current_user.usual_routes.build(usual_route_params)

    if @usual_route.save
      redirect_to my_page_path, notice: "いつもの移動を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def usual_route_params
    params.expect(usual_route: %i[name boarding_place destination_place])
  end
end
