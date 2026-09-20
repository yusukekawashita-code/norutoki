require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "ユーザー登録画面を表示できる" do
    get new_user_path

    assert_response :success
  end

  test "正しい入力でユーザーを登録できる" do
    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          name: "登録テスト",
          email: "new-user@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "ユーザー登録が完了しました", flash[:notice]
  end

  test "不正な入力ではユーザーを登録できない" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          name: "",
          email: "",
          password: "",
          password_confirmation: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
