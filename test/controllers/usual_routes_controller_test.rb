require "test_helper"

class UsualRoutesControllerTest < ActionDispatch::IntegrationTest
  test "ログイン済みユーザーはルートを登録できる" do
    user = users(:one)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    assert_difference "UsualRoute.count", 1 do
      post usual_routes_path, params: {
        usual_route: {
          name: "通勤",
          boarding_place: "自宅前",
          destination_place: "大阪駅"
        }
      }
    end

    route = UsualRoute.last

    assert_equal user, route.user
    assert_equal "通勤", route.name
    assert_equal "自宅前", route.boarding_place
    assert_equal "大阪駅", route.destination_place
    assert_redirected_to my_page_path
    assert_equal "いつもの移動を登録しました", flash[:notice]
  end

  test "入力内容が不正な場合はルートを登録できない" do
    user = users(:one)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    assert_no_difference "UsualRoute.count" do
      post usual_routes_path, params: {
        usual_route: {
          name: "",
          boarding_place: "",
          destination_place: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "li", text: "Name can't be blank"
    assert_select "li", text: "Boarding place can't be blank"
    assert_select "li", text: "Destination place can't be blank"
  end

  test "未ログインユーザーはルート登録画面にアクセスできない" do
    get new_usual_route_path

    assert_redirected_to new_session_path
    assert_equal "ログインしてください", flash[:alert]
  end

  test "ログイン中のユーザーが登録したルートだけ一覧表示される" do
    user = users(:one)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    get usual_routes_path

    assert_response :success
    assert_match usual_routes(:one).name, response.body
    assert_no_match usual_routes(:two).name, response.body
  end

  test "ルートが0件の場合は案内メッセージが表示される" do
    user = users(:one)
    user.usual_routes.destroy_all

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    get usual_routes_path

    assert_response :success
    assert_match "いつもの移動はまだ登録されていません", response.body
    assert_select "a[href='#{new_usual_route_path}']", text: "最初のルートを登録する"
  end

  test "未ログインユーザーはルート一覧画面にアクセスできない" do
    get usual_routes_path

    assert_redirected_to new_session_path
    assert_equal "ログインしてください", flash[:alert]
  end

  test "ログイン中のユーザーは自分のルート詳細を表示できる" do
    user = users(:one)
    usual_route = usual_routes(:one)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    get usual_route_path(usual_route)

    assert_response :success
    assert_match usual_route.name, response.body
    assert_match usual_route.boarding_place, response.body
    assert_match usual_route.destination_place, response.body
    assert_select "a[href='#{usual_routes_path}']", text: "ルート一覧へ戻る"
  end

  test "他のユーザーが登録したルート詳細にはアクセスできない" do
    user = users(:one)
    other_user_route = usual_routes(:two)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    get usual_route_path(other_user_route)

    assert_response :not_found
  end

  test "未ログインユーザーはルート詳細画面にアクセスできない" do
    get usual_route_path(usual_routes(:one))

    assert_redirected_to new_session_path
    assert_equal "ログインしてください", flash[:alert]
  end
end
