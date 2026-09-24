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

  test "ログイン中のユーザーは自分のルート編集画面を表示できる" do
    user = users(:one)
    usual_route = usual_routes(:one)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    get edit_usual_route_path(usual_route)

    assert_response :success
    assert_select "input[name='usual_route[name]'][value='#{usual_route.name}']"
    assert_select "input[name='usual_route[boarding_place]'][value='#{usual_route.boarding_place}']"
    assert_select "input[name='usual_route[destination_place]'][value='#{usual_route.destination_place}']"
  end

  test "ログイン中のユーザーは自分のルートを更新できる" do
    user = users(:one)
    usual_route = usual_routes(:one)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    patch usual_route_path(usual_route), params: {
      usual_route: {
        name: "更新後のルート",
        boarding_place: "更新後の出発地",
        destination_place: "更新後の目的地"
      }
    }

    usual_route.reload

    assert_equal "更新後のルート", usual_route.name
    assert_equal "更新後の出発地", usual_route.boarding_place
    assert_equal "更新後の目的地", usual_route.destination_place
    assert_redirected_to usual_route_path(usual_route)
    assert_equal "いつもの移動を更新しました", flash[:notice]
  end

  test "入力内容が不正な場合はルートを更新できない" do
    user = users(:one)
    usual_route = usual_routes(:one)
    original_name = usual_route.name

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    patch usual_route_path(usual_route), params: {
      usual_route: {
        name: "",
        boarding_place: "",
        destination_place: ""
      }
    }

    usual_route.reload

    assert_response :unprocessable_entity
    assert_equal original_name, usual_route.name
    assert_select "li", text: "Name can't be blank"
    assert_select "li", text: "Boarding place can't be blank"
    assert_select "li", text: "Destination place can't be blank"
  end

  test "他のユーザーが登録したルートの編集画面にはアクセスできない" do
    user = users(:one)
    other_user_route = usual_routes(:two)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    get edit_usual_route_path(other_user_route)

    assert_response :not_found
  end

  test "他のユーザーが登録したルートは更新できない" do
    user = users(:one)
    other_user_route = usual_routes(:two)
    original_name = other_user_route.name

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    patch usual_route_path(other_user_route), params: {
      usual_route: {
        name: "不正に更新",
        boarding_place: "不正な出発地",
        destination_place: "不正な目的地"
      }
    }

    other_user_route.reload

    assert_response :not_found
    assert_equal original_name, other_user_route.name
  end

  test "未ログインユーザーはルート編集画面にアクセスできない" do
    get edit_usual_route_path(usual_routes(:one))

    assert_redirected_to new_session_path
    assert_equal "ログインしてください", flash[:alert]
  end

  test "未ログインユーザーはルートを更新できない" do
    usual_route = usual_routes(:one)
    original_name = usual_route.name

    patch usual_route_path(usual_route), params: {
      usual_route: {
        name: "不正に更新",
        boarding_place: "不正な出発地",
        destination_place: "不正な目的地"
      }
    }

    usual_route.reload

    assert_redirected_to new_session_path
    assert_equal original_name, usual_route.name
  end

  test "ログイン中のユーザーは自分のルートを削除できる" do
    user = users(:one)
    usual_route = usual_routes(:one)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    assert_difference "UsualRoute.count", -1 do
      delete usual_route_path(usual_route)
    end

    assert_redirected_to usual_routes_path
    assert_equal "いつもの移動を削除しました", flash[:notice]
    assert_not UsualRoute.exists?(usual_route.id)
  end

  test "他のユーザーが登録したルートは削除できない" do
    user = users(:one)
    other_user_route = usual_routes(:two)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    assert_no_difference "UsualRoute.count" do
      delete usual_route_path(other_user_route)
    end

    assert_response :not_found
    assert UsualRoute.exists?(other_user_route.id)
  end

  test "未ログインユーザーはルートを削除できない" do
    usual_route = usual_routes(:one)

    assert_no_difference "UsualRoute.count" do
      delete usual_route_path(usual_route)
    end

    assert_redirected_to new_session_path
    assert_equal "ログインしてください", flash[:alert]
    assert UsualRoute.exists?(usual_route.id)
  end

  test "ルート詳細画面に削除ボタンが表示される" do
    user = users(:one)
    usual_route = usual_routes(:one)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    get usual_route_path(usual_route)

    assert_response :success
    assert_select "form[action='#{usual_route_path(usual_route)}'][method='post']" do
      assert_select "button", text: "削除する"
    end
  end

  test "ログイン中のユーザーは自分のルートを上へ移動できる" do
    user = users(:one)
    first_route = usual_routes(:one)
    first_route.update!(position: 0)

    second_route = user.usual_routes.create!(
      name: "2番目のルート",
      boarding_place: "自宅",
      destination_place: "梅田駅",
      position: 1
    )

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    patch move_up_usual_route_path(second_route)

    first_route.reload
    second_route.reload

    assert_equal 1, first_route.position
    assert_equal 0, second_route.position
    assert_redirected_to usual_routes_path
  end

  test "ログイン中のユーザーは自分のルートを下へ移動できる" do
    user = users(:one)
    first_route = usual_routes(:one)
    first_route.update!(position: 0)

    second_route = user.usual_routes.create!(
      name: "2番目のルート",
      boarding_place: "自宅",
      destination_place: "梅田駅",
      position: 1
    )

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    patch move_down_usual_route_path(first_route)

    first_route.reload
    second_route.reload

    assert_equal 1, first_route.position
    assert_equal 0, second_route.position
    assert_redirected_to usual_routes_path
  end

  test "新しいルートは末尾のpositionで登録される" do
    user = users(:one)

    first_route = user.usual_routes.create!(
      name: "1番目のルート",
      boarding_place: "A",
      destination_place: "B"
    )

    second_route = user.usual_routes.create!(
      name: "2番目のルート",
      boarding_place: "C",
      destination_place: "D"
    )

    assert_equal first_route.position + 1, second_route.position
  end

  test "他のユーザーが登録したルートは並び替えできない" do
    user = users(:one)
    other_user_route = usual_routes(:two)
    original_position = other_user_route.position

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    patch move_up_usual_route_path(other_user_route)

    other_user_route.reload

    assert_response :not_found
    assert_equal original_position, other_user_route.position
  end

  test "他のユーザーが登録したルートは下へ並び替えできない" do
    user = users(:one)
    other_user_route = usual_routes(:two)
    original_position = other_user_route.position

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    patch move_down_usual_route_path(other_user_route)

    other_user_route.reload

    assert_response :not_found
    assert_equal original_position, other_user_route.position
  end
end
