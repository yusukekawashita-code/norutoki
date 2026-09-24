class Departure < ApplicationRecord
  belongs_to :timetable

  validates :departure_time, presence: true

  def minutes_until_departure(current_time = Time.current)
    departure_seconds = seconds_since_midnight(departure_time)
    current_seconds = seconds_since_midnight(current_time)

    ((departure_seconds - current_seconds) / 60.0).ceil
  end

  private

  def seconds_since_midnight(time)
    (time.hour * 3600) + (time.min * 60) + time.sec
  end
end
