class TimetablesController < ApplicationController
  before_action :require_login
  before_action :set_usual_route

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

  private

  def set_usual_route
    @usual_route = current_user.usual_routes.find(params[:usual_route_id])
  end

  def timetable_params
    params.expect(
      timetable: [
        :day_type,
        departures_attributes: [ %i[departure_time note] ]
      ]
    )
  end
end
