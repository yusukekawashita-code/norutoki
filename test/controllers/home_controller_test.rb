require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url

    assert_response :success
  end

  test "未ログイン時はユーザー登録とログインが表示される" do
    get root_url

    assert_response :success
    assert_match "Norutoki", response.body
    assert_match "ユーザー登録", response.body
    assert_match "ログイン", response.body
    assert_no_match "ログアウト", response.body
  end

  test "ログイン時はユーザー名とログアウトが表示される" do
    user = users(:one)

    login(user)

    get root_url

    assert_response :success
    assert_match user.name, response.body
    assert_match "ログアウト", response.body
    assert_no_match "ユーザー登録", response.body
  end

  test "ログイン中は自分のルートだけがTOPページに表示される" do
    user = users(:one)

    login(user)

    get root_url

    assert_response :success
    assert_match usual_routes(:one).name, response.body
    assert_no_match usual_routes(:two).name, response.body
  end

  test "TOPページに次の便と残り時間が表示される" do
    user = users(:one)
    route = usual_routes(:one)

    route.timetables.destroy_all

    timetable = route.timetables.create!(
      day_type: Timetable::DAY_TYPES[:weekday]
    )
    timetable.departures.create!(
      departure_time: "08:10",
      note: "快速"
    )

    login(user)

    travel_to Time.zone.local(2026, 9, 25, 8, 0, 0) do
      get root_url

      assert_response :success
      assert_select ".top-next-departures__route-name", text: route.name
      assert_select ".top-next-departures__time", text: "08:10"
      assert_select ".top-next-departures__countdown", text: "あと10分"
    end
  end

  test "TOPページに行き帰り区分と出発地と目的地が表示される" do
    user = users(:one)
    route = usual_routes(:one)

    route.update!(
      direction: UsualRoute::DIRECTIONS[:outbound]
    )

    login(user)

    get root_url

    assert_response :success
    assert_select ".top-next-departures__direction", text: "行き"
    assert_match route.boarding_place, response.body
    assert_match route.destination_place, response.body
  end

  test "本日の便が終了している場合はTOPページに翌日の最初の便が表示される" do
    user = users(:one)
    route = usual_routes(:one)

    route.timetables.destroy_all

    weekday_timetable = route.timetables.create!(
      day_type: Timetable::DAY_TYPES[:weekday]
    )
    weekday_timetable.departures.create!(
      departure_time: "08:10"
    )

    saturday_timetable = route.timetables.create!(
      day_type: Timetable::DAY_TYPES[:saturday]
    )
    saturday_timetable.departures.create!(
      departure_time: "07:00",
      note: "土曜始発"
    )

    login(user)

    travel_to Time.zone.local(2026, 9, 25, 9, 0, 0) do
      get root_url

      assert_response :success
      assert_select ".top-next-departures__next-label", text: "次の運行"
      assert_select ".top-next-departures__status", text: "9月26日（土）"
      assert_select ".top-next-departures__time", text: "07:00"
      assert_select ".top-next-departures__countdown", count: 0
    end
  end

  test "ルート未登録の場合は登録を促す案内が表示される" do
    user = users(:one)

    user.usual_routes.destroy_all

    login(user)

    get root_url

    assert_response :success
    assert_select ".top-next-departures__empty"
    assert_match "いつもの移動はまだ登録されていません", response.body
    assert_select "a[href='#{new_usual_route_path}']", text: "ルートを登録する"
  end

  private

  def login(user)
    post session_path, params: {
      email: user.email,
      password: "password"
    }
  end
end
