class UsualRoutesController < ApplicationController
  before_action :require_login
  before_action :set_usual_route, only: %i[edit update destroy move_up move_down toggle_favorite]

  def index
    @direction = params[:direction]
    @usual_routes = current_user.usual_routes.ordered

    if UsualRoute::DIRECTIONS.value?(@direction.to_i) && @direction.present?
      @usual_routes = @usual_routes.where(direction: @direction)
    end
  end

  def show
    @usual_route = current_user.usual_routes.find(params[:id])

    @route_departure = RouteDepartureFinder.new(@usual_route).call
  end

  def edit
  end

  def update
    if @usual_route.update(usual_route_params)
      redirect_to usual_route_path(@usual_route), notice: "いつもの移動を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @usual_route.destroy

    redirect_to usual_routes_path, notice: "いつもの移動を削除しました"
  end

  def move_up
    @usual_route.move_up!

    redirect_to usual_routes_path
  end

  def move_down
    @usual_route.move_down!

    redirect_to usual_routes_path
  end

  def toggle_favorite
    @usual_route.update!(favorite: !@usual_route.favorite?)

    redirect_to usual_routes_path
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

  def set_usual_route
    @usual_route = current_user.usual_routes.find(params[:id])
  end

  def usual_route_params
    params.expect(usual_route: %i[name boarding_place destination_place direction note])
  end
end
