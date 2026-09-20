require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "ログイン画面を表示できる" do
    get new_session_path

    assert_response :success
  end

  test "正しいメールアドレスとパスワードでログインできる" do
    user = users(:one)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    assert_redirected_to root_path
    assert_equal user.id, session[:user_id]
    assert_equal "ログインしました", flash[:notice]
  end

  test "誤ったパスワードではログインできない" do
    user = users(:one)

    post session_path, params: {
      email: user.email,
      password: "wrong_password"
    }

    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_equal "メールアドレスまたはパスワードが正しくありません", flash[:alert]
    assert_includes response.body, "メールアドレスまたはパスワードが正しくありません"
  end

  test "ログアウトできる" do
    user = users(:one)

    post session_path, params: {
      email: user.email,
      password: "password"
    }

    assert_equal user.id, session[:user_id]

    delete session_path

    assert_redirected_to root_path
    assert_nil session[:user_id]
    assert_equal "ログアウトしました", flash[:notice]
  end
end
