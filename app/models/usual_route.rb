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

  def move_up!
    previous_route = user.usual_routes
                         .where("position < ?", position)
                         .order(position: :desc)
                         .first

    swap_position_with!(previous_route)
  end

  def move_down!
    next_route = user.usual_routes
                     .where("position > ?", position)
                     .order(position: :asc)
                     .first

    swap_position_with!(next_route)
  end

  private

  def swap_position_with!(other_route)
    return unless other_route

    self.class.transaction do
      current_position = position

      update!(position: other_route.position)
      other_route.update!(position: current_position)
    end
  end

  def set_position
    self.position = (user.usual_routes.maximum(:position) || -1) + 1
  end
end
