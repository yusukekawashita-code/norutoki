require "test_helper"

class TimetableTest < ActiveSupport::TestCase
  test "usual_routeとday_typeがあれば有効" do
    timetable = Timetable.new(
      usual_route: usual_routes(:one),
      day_type: 1
    )

    assert timetable.valid?
  end

  test "usual_routeがなければ無効" do
    timetable = Timetable.new(
      usual_route: nil,
      day_type: 1
    )

    assert_not timetable.valid?
    assert_includes timetable.errors[:usual_route], "must exist"
  end

  test "day_typeがなければ無効" do
    timetable = Timetable.new(
      usual_route: usual_routes(:one),
      day_type: nil
    )

    assert_not timetable.valid?
    assert_includes timetable.errors[:day_type], "can't be blank"
  end

  test "usual_routeに紐づくtimetablesを取得できる" do
    usual_route = usual_routes(:one)
    timetable = timetables(:one)

    assert_includes usual_route.timetables, timetable
  end

  test "usual_routeを削除すると紐づくtimetablesも削除される" do
    usual_route = usual_routes(:one)

    assert_difference "Timetable.count", -1 do
      usual_route.destroy
    end
  end

  test "現在時刻以降で最も近い便を取得できる" do
    timetable = timetables(:one)
    timetable.departures.destroy_all

    timetable.departures.create!(departure_time: "08:10", note: "1便目")
    timetable.departures.create!(departure_time: "08:30", note: "2便目")
    timetable.departures.create!(departure_time: "09:00", note: "3便目")

    current_time = Time.zone.parse("08:25")

    next_departure = timetable.next_departure(current_time)

    assert_equal "08:30", next_departure.departure_time.strftime("%H:%M")
  end

  test "現在時刻と同じ時刻の便を取得できる" do
    timetable = timetables(:one)
    timetable.departures.destroy_all

    timetable.departures.create!(departure_time: "08:10")
    timetable.departures.create!(departure_time: "08:30")
    timetable.departures.create!(departure_time: "09:00")

    current_time = Time.zone.parse("08:30")

    next_departure = timetable.next_departure(current_time)

    assert_equal "08:30", next_departure.departure_time.strftime("%H:%M")
  end

  test "登録順に関係なく最も近い便を取得できる" do
    timetable = timetables(:one)
    timetable.departures.destroy_all

    timetable.departures.create!(departure_time: "09:00")
    timetable.departures.create!(departure_time: "08:10")
    timetable.departures.create!(departure_time: "08:30")

    current_time = Time.zone.parse("08:25")

    next_departure = timetable.next_departure(current_time)

    assert_equal "08:30", next_departure.departure_time.strftime("%H:%M")
  end

  test "本日の便がすべて終了している場合はnilを返す" do
    timetable = timetables(:one)
    timetable.departures.destroy_all

    timetable.departures.create!(departure_time: "08:10")
    timetable.departures.create!(departure_time: "08:30")
    timetable.departures.create!(departure_time: "09:00")

    current_time = Time.zone.parse("10:00")

    assert_nil timetable.next_departure(current_time)
  end

  test "時刻表が登録されていない場合はnilを返す" do
    timetable = timetables(:one)
    timetable.departures.destroy_all

    current_time = Time.zone.parse("08:25")

    assert_nil timetable.next_departure(current_time)
  end

  test "時刻を指定しない場合は現在時刻を基準に次の便を取得できる" do
    timetable = timetables(:one)
    timetable.departures.destroy_all

    travel_to Time.zone.local(2026, 9, 24, 8, 25) do
      timetable.departures.create!(departure_time: "08:10")
      timetable.departures.create!(departure_time: "08:30")
      timetable.departures.create!(departure_time: "09:00")

      next_departure = timetable.next_departure

      assert_equal "08:30", next_departure.departure_time.strftime("%H:%M")
    end
  end

  test "平日はday_type 0を返す" do
    date = Date.new(2026, 9, 24)

    assert_equal 0, Timetable.today_day_type(date)
  end

  test "土曜日はday_type 1を返す" do
    date = Date.new(2026, 9, 26)

    assert_equal 1, Timetable.today_day_type(date)
  end

  test "日曜日はday_type 2を返す" do
    date = Date.new(2026, 9, 27)

    assert_equal 2, Timetable.today_day_type(date)
  end

  test "day_typeが0・1・2以外なら無効" do
    timetable = Timetable.new(
      usual_route: usual_routes(:one),
      day_type: 3
    )

    assert_not timetable.valid?
    assert_includes timetable.errors[:day_type], "is not included in the list"
  end
end
