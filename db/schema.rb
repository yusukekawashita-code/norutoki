# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_23_162035) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "departures", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.time "departure_time", null: false
    t.string "note"
    t.bigint "timetable_id", null: false
    t.datetime "updated_at", null: false
    t.index ["timetable_id"], name: "index_departures_on_timetable_id"
  end

  create_table "timetables", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "usual_route_id", null: false
    t.index ["usual_route_id"], name: "index_timetables_on_usual_route_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "usual_routes", force: :cascade do |t|
    t.string "boarding_place", null: false
    t.datetime "created_at", null: false
    t.string "destination_place", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_usual_routes_on_user_id"
  end

  add_foreign_key "departures", "timetables"
  add_foreign_key "timetables", "usual_routes"
  add_foreign_key "usual_routes", "users"
end
