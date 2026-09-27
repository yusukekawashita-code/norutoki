class UsualRoute < ApplicationRecord
  DIRECTIONS = {
    outbound: 0,
    inbound: 1
  }.freeze

  belongs_to :user

  has_many :timetables, dependent: :destroy

  scope :ordered, -> { order(:position, :id) }

  before_create :set_position

  validates :name, presence: true
  validates :boarding_place, presence: true
  validates :destination_place, presence: true
  validates :direction,
            presence: true,
            inclusion: { in: DIRECTIONS.values }

  private

  def set_position
    self.position = (user.usual_routes.maximum(:position) || -1) + 1
  end
end
