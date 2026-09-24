class NextDeparturesController < ApplicationController
  before_action :require_login

  def index
    current_time = Time.current
    day_type = Timetable.today_day_type(current_time.to_date)

    @route_departures = current_user.usual_routes.includes(timetables: :departures).map do |usual_route|
      timetable = usual_route.timetables.find { |item| item.day_type == day_type }
      next_departure = timetable&.next_departure(current_time)

      {
        usual_route: usual_route,
        timetable: timetable,
        next_departure: next_departure,
        minutes_until_departure: next_departure&.minutes_until_departure(current_time)
      }
    end
  end
end
