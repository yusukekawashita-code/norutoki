class CreateDepartures < ActiveRecord::Migration[8.1]
  def change
    create_table :departures do |t|
      t.references :timetable, null: false, foreign_key: true
      t.time :departure_time, null: false
      t.string :note

      t.timestamps
    end
  end
end
