require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(
      name: "テストユーザー",
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )

    assert user.valid?
  end

  test "invalid without name" do
    user = User.new(
      name: "",
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )

    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "invalid without email" do
    user = User.new(
      name: "テストユーザー",
      email: "",
      password: "password",
      password_confirmation: "password"
    )

    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "invalid with duplicate email" do
    existing_user = users(:one)

    user = User.new(
      name: "テストユーザー",
      email: existing_user.email,
      password: "password",
      password_confirmation: "password"
    )

    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "authenticates with correct password" do
    user = users(:one)

    assert user.authenticate("password")
    assert_not user.authenticate("wrong_password")
  end
end
