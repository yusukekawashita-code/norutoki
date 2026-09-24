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

    test "ログイン中のユーザーは自分のルートの時刻表一覧を表示できる" do
    post session_path, params: {
      email: @user.email,
      password: "password"
    }

    get usual_route_timetables_path(@usual_route)

    assert_response :success
    assert_select "h1", "時刻表一覧"
    assert_select ".timetable-index__card"
  end

  test "時刻表一覧では出発時刻が早い順に表示される" do
    post session_path, params: {
      email: @user.email,
      password: "password"
    }

    timetable = timetables(:one)

    timetable.departures.create!(
      departure_time: "10:00",
      note: "遅い便"
    )

    timetable.departures.create!(
      departure_time: "07:30",
      note: "早い便"
    )

    get usual_route_timetables_path(@usual_route)

    assert_response :success

    times = css_select(".timetable-index__time").map { |element| element.text.strip }

    assert_equal times.sort, times
    assert_includes times, "07:30"
    assert_includes times, "10:00"
  end

  test "ログイン中のユーザーは自分の時刻表編集画面を表示できる" do
    post session_path, params: {
      email: @user.email,
      password: "password"
    }

    timetable = timetables(:one)

    get edit_usual_route_timetable_path(@usual_route, timetable)

    assert_response :success
    assert_select "h1", "時刻表を編集"
  end

  test "ログイン中のユーザーは自分の時刻表を更新できる" do
    post session_path, params: {
      email: @user.email,
      password: "password"
    }

    timetable = timetables(:one)
    departure = departures(:one)

    patch usual_route_timetable_path(@usual_route, timetable), params: {
      timetable: {
        day_type: 1,
        departures_attributes: {
          "0" => {
            id: departure.id,
            departure_time: "08:20",
            note: "更新後"
          }
        }
      }
    }

    timetable.reload
    departure.reload

    assert_equal 1, timetable.day_type
    assert_equal "08:20", departure.departure_time.strftime("%H:%M")
    assert_equal "更新後", departure.note
    assert_redirected_to usual_route_timetables_path(@usual_route)
    assert_equal "時刻表を更新しました", flash[:notice]
  end

  test "不正な値では時刻表を更新できない" do
    post session_path, params: {
      email: @user.email,
      password: "password"
    }

    timetable = timetables(:one)
    departure = departures(:one)
    original_time = departure.departure_time

    patch usual_route_timetable_path(@usual_route, timetable), params: {
      timetable: {
        day_type: timetable.day_type,
        departures_attributes: {
          "0" => {
            id: departure.id,
            departure_time: "",
            note: departure.note
          }
        }
      }
    }

    assert_response :unprocessable_entity
    assert_select ".timetable-form__errors"

    departure.reload
    assert_equal original_time, departure.departure_time
  end

  test "他のユーザーの時刻表編集画面は表示できない" do
    post session_path, params: {
      email: @user.email,
      password: "password"
    }

    other_route = usual_routes(:two)
    other_timetable = timetables(:two)

    get edit_usual_route_timetable_path(other_route, other_timetable)

    assert_response :not_found
  end

  test "他のユーザーの時刻表は更新できない" do
    post session_path, params: {
      email: @user.email,
      password: "password"
    }

    other_route = usual_routes(:two)
    other_timetable = timetables(:two)
    original_day_type = other_timetable.day_type

    patch usual_route_timetable_path(other_route, other_timetable), params: {
      timetable: {
        day_type: 0
      }
    }

    assert_response :not_found

    other_timetable.reload
    assert_equal original_day_type, other_timetable.day_type
  end
end
