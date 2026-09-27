class AddDirectionToUsualRoutes < ActiveRecord::Migration[8.1]
  def change
    add_column :usual_routes, :direction, :integer, null: false, default: 0
  end
end
