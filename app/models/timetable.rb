class Timetable < ApplicationRecord
  belongs_to :usual_route

  has_many :departures, dependent: :destroy

  accepts_nested_attributes_for :departures,
                                reject_if: :all_blank,
                                allow_destroy: true

  validates :day_type, presence: true

  def next_departure(current_time = Time.current)
    current_clock = current_time.strftime("%H:%M:%S")

    departures
      .where("departure_time >= ?", current_clock)
      .order(:departure_time)
      .first
  end
end
