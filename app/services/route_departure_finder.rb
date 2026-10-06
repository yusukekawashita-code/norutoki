class RouteDepartureFinder
  def initialize(usual_route, current_time = Time.current)
    @usual_route = usual_route
    @current_time = current_time
  end

  def call
    timetable = find_timetable(day_type)
    next_departure = timetable&.next_departure(current_time)

    tomorrow_timetable = nil
    tomorrow_departure = nil

    if timetable.present? && next_departure.nil?
      tomorrow_timetable = find_timetable(tomorrow_day_type)
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

  private

  attr_reader :usual_route, :current_time

  def day_type
    Timetable.today_day_type(current_time.to_date)
  end

  def tomorrow_day_type
    Timetable.today_day_type(current_time.to_date.tomorrow)
  end

  def find_timetable(target_day_type)
    usual_route.timetables
              .includes(:departures)
              .find_by(day_type: target_day_type)
  end
end
