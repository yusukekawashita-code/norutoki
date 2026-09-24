require "test_helper"

class DepartureTest < ActiveSupport::TestCase
  test "timetableとdeparture_timeがあれば有効" do
    departure = Departure.new(
      timetable: timetables(:one),
      departure_time: "08:10"
    )

    assert departure.valid?
  end

  test "timetableがなければ無効" do
    departure = Departure.new(
      timetable: nil,
      departure_time: "08:10"
    )

    assert_not departure.valid?
    assert_includes departure.errors[:timetable], "must exist"
  end

  test "departure_timeがなければ無効" do
    departure = Departure.new(
      timetable: timetables(:one),
      departure_time: nil
    )

    assert_not departure.valid?
    assert_includes departure.errors[:departure_time], "can't be blank"
  end

  test "timetableを削除すると紐づくdeparturesも削除される" do
    timetable = timetables(:one)

    assert_difference "Departure.count", -1 do
      timetable.destroy
    end
  end

  test "現在時刻から出発時刻までの残り時間を分で取得できる" do
    departure = Departure.new(
      timetable: timetables(:one),
      departure_time: "17:20"
    )

    current_time = Time.zone.local(2026, 9, 25, 17, 5, 0)

    assert_equal 15, departure.minutes_until_departure(current_time)
  end

  test "出発1分前は残り1分を返す" do
    departure = Departure.new(
      timetable: timetables(:one),
      departure_time: "17:20"
    )

    current_time = Time.zone.local(2026, 9, 25, 17, 19, 0)

    assert_equal 1, departure.minutes_until_departure(current_time)
  end

  test "出発時刻と現在時刻が同じ場合は0分を返す" do
    departure = Departure.new(
      timetable: timetables(:one),
      departure_time: "17:20"
    )

    current_time = Time.zone.local(2026, 9, 25, 17, 20, 0)

    assert_equal 0, departure.minutes_until_departure(current_time)
  end
end
