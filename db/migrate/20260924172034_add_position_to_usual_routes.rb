class AddPositionToUsualRoutes < ActiveRecord::Migration[8.1]
  class UsualRoute < ActiveRecord::Base
    self.table_name = "usual_routes"
  end

  def up
    add_column :usual_routes, :position, :integer, null: false, default: 0

    UsualRoute.reset_column_information

    UsualRoute.distinct.pluck(:user_id).each do |user_id|
      UsualRoute.where(user_id: user_id)
                .order(:created_at, :id)
                .each_with_index do |route, index|
        route.update_columns(position: index)
      end
    end
  end

  def down
    remove_column :usual_routes, :position
  end
end
