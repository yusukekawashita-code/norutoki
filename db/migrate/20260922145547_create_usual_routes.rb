class CreateUsualRoutes < ActiveRecord::Migration[8.1]
  def change
    create_table :usual_routes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :boarding_place, null: false
      t.string :destination_place, null: false

      t.timestamps
    end
  end
end
