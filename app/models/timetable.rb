class Timetable < ApplicationRecord
  belongs_to :usual_route

  has_many :departures, dependent: :destroy

  accepts_nested_attributes_for :departures,
                                reject_if: :all_blank,
                                allow_destroy: true

  validates :day_type, presence: true
end
