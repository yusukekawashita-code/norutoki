require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url

    assert_response :success
  end

  test "未ログイン時はログアウトボタンが表示されない" do
    get root_url

    assert_response :success
    assert_no_match "ログアウト", response.body
  end

  test "ログイン時はログアウトボタンが表示される" do
    user = users(:one)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    get root_url

    assert_response :success
    assert_match "ログアウト", response.body
  end
end
