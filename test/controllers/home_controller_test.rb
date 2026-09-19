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

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    get root_url

    assert_response :success
    assert_match user.name, response.body
    assert_match "ログアウト", response.body
    assert_no_match "ユーザー登録", response.body
  end
end
