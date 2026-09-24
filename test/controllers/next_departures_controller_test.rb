require "test_helper"

class NextDeparturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @usual_route = usual_routes(:one)
  end

  test "ログイン中のユーザーは次の便画面を表示できる" do
    login

    get next_departures_path

    assert_response :success
    assert_select "h1", text: "次の便"
  end

  test "自分のルートだけが表示される" do
    login

    get next_departures_path

    assert_response :success
    assert_select ".next-departures__route-name", text: @usual_route.name
    assert_select ".next-departures__route-name", text: usual_routes(:two).name, count: 0
  end

  test "現在時刻以降で最も近い便が表示される" do
    timetable = timetables(:one)
    timetable.update!(day_type: 0)
    timetable.departures.destroy_all

    timetable.departures.create!(
      departure_time: "08:30",
      note: "普通"
    )
    timetable.departures.create!(
      departure_time: "08:10",
      note: "快速"
    )

    login

    travel_to Time.zone.local(2026, 9, 25, 8, 0, 0) do
      get next_departures_path

      assert_response :success
      assert_select ".next-departures__time", text: "08:10"
      assert_select ".next-departures__countdown", text: "あと10分"
      assert_select ".next-departures__note", text: "快速"
    end
  end

  test "時間の経過後に再読み込みすると残り時間が更新される" do
    timetable = timetables(:one)
    timetable.update!(day_type: 0)
    timetable.departures.destroy_all

    timetable.departures.create!(
      departure_time: "08:10",
      note: "快速"
    )

    login

    travel_to Time.zone.local(2026, 9, 25, 8, 0, 0) do
      get next_departures_path

      assert_response :success
      assert_select ".next-departures__countdown", text: "あと10分"
    end

    travel_to Time.zone.local(2026, 9, 25, 8, 5, 0) do
      get next_departures_path

      assert_response :success
      assert_select ".next-departures__countdown", text: "あと5分"
    end
  end

  test "本日の便がすべて終了している場合はその旨を表示する" do
    timetable = timetables(:one)
    timetable.update!(day_type: 0)
    timetable.departures.destroy_all

    timetable.departures.create!(
      departure_time: "08:10",
      note: "快速"
    )

    login

    travel_to Time.zone.local(2026, 9, 25, 9, 0, 0) do
      get next_departures_path

      assert_response :success
      assert_select ".next-departures__status", text: "本日の便は終了しました"
      assert_select ".next-departures__countdown", count: 0
    end
  end

  test "本日の時刻表が登録されていない場合はその旨を表示する" do
    @usual_route.timetables.destroy_all

    login

    travel_to Time.zone.local(2026, 9, 25, 8, 0, 0) do
      get next_departures_path

      assert_response :success
      assert_select ".next-departures__status",
                    text: "時刻表が登録されていません"
      assert_select ".next-departures__countdown", count: 0
    end
  end

  test "未ログインユーザーは次の便画面を表示できない" do
    get next_departures_path

    assert_redirected_to new_session_path
    assert_equal "ログインしてください", flash[:alert]
  end

  private

  def login
    post session_path, params: {
      email: @user.email,
      password: "password"
    }
  end
end
