require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "存在しないURLにアクセスすると404画面が表示される" do
    get "/this-page-does-not-exist"

    assert_response :not_found
    assert_select ".error-page__code", text: "404"
    assert_select ".error-page__title", text: "ページが見つかりませんでした"
    assert_select "a[href='#{root_path}']", text: "トップページへ戻る"
  end
end
