class NextDeparturesController < ApplicationController
  before_action :require_login

  def index
    current_time = Time.current
    day_type = Timetable.today_day_type(current_time.to_date)
    tomorrow_day_type = Timetable.today_day_type(current_time.to_date.tomorrow)

    @route_departures = current_user.usual_routes
                                    .ordered
                                    .includes(timetables: :departures)
                                    .map do |usual_route|
      timetable = usual_route.timetables.find { |item| item.day_type == day_type }
      next_departure = timetable&.next_departure(current_time)

      tomorrow_timetable = nil
      tomorrow_departure = nil

      if timetable.present? && next_departure.nil?
        tomorrow_timetable = usual_route.timetables.find do |item|
          item.day_type == tomorrow_day_type
        end

        tomorrow_departure = tomorrow_timetable&.first_departure
      end

      {
        usual_route: usual_route,
        timetable: timetable,
        next_departure: next_departure,
        minutes_until_departure: next_departure&.minutes_until_departure(current_time),
        tomorrow_timetable: tomorrow_timetable,
        tomorrow_departure: tomorrow_departure
      }
    end
  end
end
