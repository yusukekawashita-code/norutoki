class UsualRoutesController < ApplicationController
  before_action :require_login
  before_action :set_usual_route, only: %i[show edit update destroy move_up move_down toggle_favorite]

  def index
    @usual_routes = current_user.usual_routes.ordered
  end

  def show
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
    previous_route = current_user.usual_routes
                                .where("position < ?", @usual_route.position)
                                .order(position: :desc)
                                .first

    if previous_route
      UsualRoute.transaction do
        current_position = @usual_route.position

        @usual_route.update!(position: previous_route.position)
        previous_route.update!(position: current_position)
      end
    end

    redirect_to usual_routes_path
  end

  def move_down
    next_route = current_user.usual_routes
                            .where("position > ?", @usual_route.position)
                            .order(position: :asc)
                            .first

    if next_route
      UsualRoute.transaction do
        current_position = @usual_route.position

        @usual_route.update!(position: next_route.position)
        next_route.update!(position: current_position)
      end
    end

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
    params.expect(usual_route: %i[name boarding_place destination_place])
  end
end
