class Timetable < ApplicationRecord
  belongs_to :usual_route

  has_many :departures, dependent: :destroy

  accepts_nested_attributes_for :departures,
                                reject_if: :all_blank,
                                allow_destroy: true

  validates :day_type, presence: true

  def next_departure(current_time = Time.current)
    current_seconds = seconds_since_midnight(current_time)

    departures
      .select { |departure| seconds_since_midnight(departure.departure_time) >= current_seconds }
      .min_by { |departure| seconds_since_midnight(departure.departure_time) }
  end

  def self.today_day_type(date = Time.zone.today)
    date.saturday? || date.sunday? ? 1 : 0
  end

  private

  def seconds_since_midnight(time)
    (time.hour * 3600) + (time.min * 60) + time.sec
  end
end
