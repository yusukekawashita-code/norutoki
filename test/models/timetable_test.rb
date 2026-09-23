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
end
