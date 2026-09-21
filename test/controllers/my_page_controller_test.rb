require "test_helper"

class MyPageControllerTest < ActionDispatch::IntegrationTest
  test "未ログインの場合はログイン画面へリダイレクトされる" do
    get my_page_url

    assert_redirected_to new_session_path
    assert_equal "ログインしてください", flash[:alert]
  end

  test "ログイン済みの場合はマイページを表示できる" do
    user = users(:one)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    get my_page_url

    assert_response :success
  end
end
