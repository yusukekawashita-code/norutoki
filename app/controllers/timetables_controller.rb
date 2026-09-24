class TimetablesController < ApplicationController
  before_action :require_login
  before_action :set_usual_route
  before_action :set_timetable, only: %i[edit update]

  def index
    @timetables = @usual_route.timetables.includes(:departures).order(:day_type)
  end

  def new
    @timetable = @usual_route.timetables.build

    3.times do
      @timetable.departures.build
    end
  end

  def create
    @timetable = @usual_route.timetables.build(timetable_params)

    if @timetable.save
      redirect_to usual_route_path(@usual_route), notice: "時刻表を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @timetable.update(timetable_params)
      redirect_to usual_route_timetables_path(@usual_route), notice: "時刻表を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_usual_route
    @usual_route = current_user.usual_routes.find(params[:usual_route_id])
  end

  def set_timetable
    @timetable = @usual_route.timetables.find(params[:id])
  end

  def timetable_params
    params.expect(
      timetable: [
        :day_type,
        departures_attributes: [ %i[id departure_time note _destroy] ]
      ]
    )
  end
end
