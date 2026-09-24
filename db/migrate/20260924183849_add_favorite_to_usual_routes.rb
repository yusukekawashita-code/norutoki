class AddFavoriteToUsualRoutes < ActiveRecord::Migration[8.1]
  def change
    add_column :usual_routes, :favorite, :boolean, null: false, default: false
  end
end
