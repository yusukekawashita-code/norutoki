class AddNoteToUsualRoutes < ActiveRecord::Migration[8.1]
  def change
    add_column :usual_routes, :note, :text
  end
end
