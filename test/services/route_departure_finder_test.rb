require "test_helper"

class RouteDepartureFinderTest < ActiveSupport::TestCase
  setup do
    @usual_route = usual_routes(:one)
  end

  test "今日の次便を取得できる" do
    current_time = Time.zone.local(2026, 10, 10, 8, 0) # 土曜日

    result = RouteDepartureFinder.new(@usual_route, current_time).call

    assert_equal timetables(:one), result[:timetable]
    assert_equal departures(:one), result[:next_departure]
  end

  test "水曜日に土曜だけ登録されている場合は次の土曜の始発を取得できる" do
    current_time = Time.zone.local(2026, 10, 7, 8, 0) # 水曜日

    result = RouteDepartureFinder.new(@usual_route, current_time).call

    assert_equal Date.new(2026, 10, 10), result[:next_service_date]
    assert_equal departures(:one), result[:next_service_departure]
  end

  test "土曜日に日曜祝日だけ登録されている場合は次の日曜の始発を取得できる" do
    @usual_route.timetables.destroy_all

    timetable = @usual_route.timetables.create!(day_type: Timetable::DAY_TYPES[:sunday_holiday])
    departure = timetable.departures.create!(departure_time: "09:15")

    current_time = Time.zone.local(2026, 10, 10, 8, 0) # 土曜日

    result = RouteDepartureFinder.new(@usual_route, current_time).call

    assert_equal Date.new(2026, 10, 11), result[:next_service_date]
    assert_equal departure, result[:next_service_departure]
  end

  test "翌日が祝日の場合は次の平日の始発を取得できる" do
    @usual_route.timetables.destroy_all

    timetable = @usual_route.timetables.create!(day_type: Timetable::DAY_TYPES[:weekday])
    departure = timetable.departures.create!(departure_time: "07:30")

    current_time = Time.zone.local(2026, 10, 11, 8, 0) # 日曜日

    result = RouteDepartureFinder.new(@usual_route, current_time).call

    assert_equal Date.new(2026, 10, 13), result[:next_service_date]
    assert_equal departure, result[:next_service_departure]
  end

  test "祝日当日は日曜祝日の次便を取得できる" do
    @usual_route.timetables.destroy_all

    timetable = @usual_route.timetables.create!(
      day_type: Timetable::DAY_TYPES[:sunday_holiday]
    )
    departure = timetable.departures.create!(
      departure_time: "09:15",
      note: "祝日便"
    )

    current_time = Time.zone.local(2026, 10, 12, 8, 0) # スポーツの日（月曜日）

    result = RouteDepartureFinder.new(@usual_route, current_time).call

    assert_equal timetable, result[:timetable]
    assert_equal departure, result[:next_departure]
  end
end
