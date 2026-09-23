class UsualRoute < ApplicationRecord
  belongs_to :user

  has_many :timetables, dependent: :destroy

  validates :name, presence: true
  validates :boarding_place, presence: true
  validates :destination_place, presence: true
end
