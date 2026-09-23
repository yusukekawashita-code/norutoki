require "test_helper"

class TimetablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @usual_route = usual_routes(:one)
  end

  test "ログイン中のユーザーは自分のルートの時刻表登録画面を表示できる" do
    post session_path, params: {
      email: @user.email,
      password: "password"
    }

    get new_usual_route_timetable_path(@usual_route)

    assert_response :success
    assert_select "h1", "時刻表を登録"
  end

  test "ログイン中のユーザーは自分のルートに複数の出発時刻を登録できる" do
    post session_path, params: {
      email: @user.email,
      password: "password"
    }

    assert_difference "Timetable.count", 1 do
      assert_difference "Departure.count", 2 do
        post usual_route_timetables_path(@usual_route), params: {
          timetable: {
            day_type: 0,
            departures_attributes: {
              "0" => {
                departure_time: "08:10",
                note: "快速"
              },
              "1" => {
                departure_time: "08:30",
                note: ""
              }
            }
          }
        }
      end
    end

    timetable = Timetable.order(:created_at).last

    assert_equal @usual_route, timetable.usual_route
    assert_equal 0, timetable.day_type
    assert_equal 2, timetable.departures.count
    assert_redirected_to usual_route_path(@usual_route)
    assert_equal "時刻表を登録しました", flash[:notice]
  end

  test "不正な値では時刻表を登録できない" do
    post session_path, params: {
      email: @user.email,
      password: "password"
    }

    assert_no_difference "Timetable.count" do
      post usual_route_timetables_path(@usual_route), params: {
        timetable: {
          day_type: "",
          departures_attributes: {
            "0" => {
              departure_time: "08:10",
              note: ""
            }
          }
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".timetable-form__errors"
  end

  test "他のユーザーのルートには時刻表を登録できない" do
    post session_path, params: {
      email: @user.email,
      password: "password"
    }

    other_route = usual_routes(:two)

    assert_no_difference "Timetable.count" do
      post usual_route_timetables_path(other_route), params: {
        timetable: {
          day_type: 0,
          departures_attributes: {
            "0" => {
              departure_time: "08:10",
              note: ""
            }
          }
        }
      }
    end

    assert_response :not_found
  end

  test "ログアウト中のユーザーは時刻表登録画面を表示できない" do
    get new_usual_route_timetable_path(@usual_route)

    assert_redirected_to new_session_path
    assert_equal "ログインしてください", flash[:alert]
  end
end
