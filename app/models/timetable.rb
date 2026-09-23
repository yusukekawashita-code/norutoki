class Timetable < ApplicationRecord
  belongs_to :usual_route

  validates :day_type, presence: true
end
