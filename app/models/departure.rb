class Departure < ApplicationRecord
  belongs_to :timetable

  validates :departure_time, presence: true
end
