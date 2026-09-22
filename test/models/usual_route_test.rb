require "test_helper"

class UsualRouteTest < ActiveSupport::TestCase
  test "有効なルートを登録できる" do
    route = UsualRoute.new(
      user: users(:one),
      name: "通勤",
      boarding_place: "自宅前",
      destination_place: "大阪駅"
    )

    assert route.valid?
  end

  test "ルート名は必須である" do
    route = usual_routes(:one)
    route.name = nil

    assert_not route.valid?
  end

  test "乗車地は必須である" do
    route = usual_routes(:one)
    route.boarding_place = nil

    assert_not route.valid?
  end

  test "降車地は必須である" do
    route = usual_routes(:one)
    route.destination_place = nil

    assert_not route.valid?
  end

  test "ユーザーに紐づいている" do
    route = usual_routes(:one)

    assert_equal users(:one), route.user
  end
end
