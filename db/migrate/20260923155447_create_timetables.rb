class CreateTimetables < ActiveRecord::Migration[8.1]
  def change
    create_table :timetables do |t|
      t.references :usual_route, null: false, foreign_key: true
      t.integer :day_type, null: false

      t.timestamps
    end
  end
end
