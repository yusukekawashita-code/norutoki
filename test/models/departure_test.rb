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
end
