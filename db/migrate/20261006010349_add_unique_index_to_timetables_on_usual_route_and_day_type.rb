class AddUniqueIndexToTimetablesOnUsualRouteAndDayType < ActiveRecord::Migration[8.1]
  def change
    add_index :timetables,
              %i[usual_route_id day_type],
              unique: true,
              name: "index_timetables_on_route_and_day_type"
  end
end
