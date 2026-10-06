class RouteDepartureFinder
  SEARCH_DAYS = 7

  def initialize(usual_route, current_time = Time.current)
    @usual_route = usual_route
    @current_time = current_time
  end

  def call
    timetable = find_timetable(day_type)
    next_departure = timetable&.next_departure(current_time)

    next_service = find_next_service unless next_departure.present?

    {
      usual_route: usual_route,
      timetable_registered: usual_route.timetables.exists?,
      timetable: timetable,
      next_departure: next_departure,
      minutes_until_departure: next_departure&.minutes_until_departure(current_time),
      next_service_date: next_service&.fetch(:date),
      next_service_timetable: next_service&.fetch(:timetable),
      next_service_departure: next_service&.fetch(:departure)
    }
  end

  private

  attr_reader :usual_route, :current_time

  def day_type
    Timetable.today_day_type(current_time.to_date)
  end

  def find_next_service
    (1..SEARCH_DAYS).each do |days_ahead|
      date = current_time.to_date + days_ahead.days
      timetable = find_timetable(Timetable.today_day_type(date))
      departure = timetable&.first_departure

      next unless departure.present?

      return {
        date: date,
        timetable: timetable,
        departure: departure
      }
    end

    nil
  end

  def find_timetable(target_day_type)
    usual_route.timetables
               .includes(:departures)
               .find_by(day_type: target_day_type)
  end
end
