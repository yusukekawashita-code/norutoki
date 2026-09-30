require "application_system_test_case"

class UserFlowsTest < ApplicationSystemTestCase
  setup do
    Capybara.reset_sessions!
  end

  test "ユーザー登録してログイン後にルートと時刻表を登録できる" do
    # ユーザー登録
    visit new_user_path

    fill_in "名前", with: "システムテスト太郎"
    fill_in "メールアドレス", with: "system-test@example.com"
    fill_in "パスワード", with: "password"
    fill_in "パスワード確認", with: "password"

    assert_field "名前", with: "システムテスト太郎"
    assert_field "メールアドレス", with: "system-test@example.com"
    assert_field "パスワード", with: "password"
    assert_field "パスワード確認", with: "password"

    click_button "登録する"

    assert_text "ユーザー登録が完了しました"
    assert_current_path root_path

    # ログイン
    visit new_session_path

    fill_in "メールアドレス", with: "system-test@example.com"
    fill_in "パスワード", with: "password"

    click_button "ログイン"

    assert_text "ログインしました"
    assert_current_path root_path

    # いつもの移動を登録
    visit new_usual_route_path

    fill_in "ルート名", with: "通勤"
    fill_in "出発地", with: "堺"
    fill_in "目的地", with: "難波"
    select "行き", from: "ルート区分"
    fill_in "メモ", with: "朝は駅前のバス停を利用"

    click_button "登録する"

    assert_text "いつもの移動を登録しました"
    assert_text "通勤"
    assert_text "堺"
    assert_text "難波"

    # ルート一覧から登録したルートの詳細を開く
    click_link "ルート一覧を見る"

    assert_text "いつもの移動"
    assert_text "通勤"

    click_link "通勤"

    assert_text "ルート詳細"
    assert_text "通勤"
    assert_text "堺"
    assert_text "難波"

    # 時刻表を登録
    click_link "時刻表を登録する", match: :first

    select "平日", from: "曜日区分"
    all("input[type='time']").first.fill_in(with: "08:30")
    all(".timetable-form__departure input[type='text']").first.fill_in(with: "快速")

    click_button "登録する"

    assert_text "時刻表を登録しました"
    assert_text "08:30"
    assert_text "快速"

    # 次の便一覧を確認
    visit next_departures_path

    assert_text "次の便"
    assert_text "通勤"
    assert_text "行き"
    assert_text "堺"
    assert_text "難波"
  end

  test "登録したルートを編集できる" do
    # ユーザー登録
    visit new_user_path

    fill_in "名前", with: "編集テスト太郎"
    fill_in "メールアドレス", with: "edit-test@example.com"
    fill_in "パスワード", with: "password"
    fill_in "パスワード確認", with: "password"

    click_button "登録する"

    assert_text "ユーザー登録が完了しました"
    assert_current_path root_path

    # ログイン
    visit new_session_path

    fill_in "メールアドレス", with: "edit-test@example.com"
    fill_in "パスワード", with: "password"

    click_button "ログイン"

    assert_text "ログインしました"
    assert_current_path root_path

    # ルート登録
    visit new_usual_route_path

    fill_in "ルート名", with: "通勤"
    fill_in "出発地", with: "堺"
    fill_in "目的地", with: "難波"
    select "行き", from: "ルート区分"
    fill_in "メモ", with: "朝の通勤"

    click_button "登録する"

    # ルート詳細へ移動
    click_link "ルート一覧を見る"
    click_link "通勤"

    # 編集
    click_link "編集する"

    assert_text "ルートを編集"

    fill_in "ルート名", with: "通勤ルート"
    fill_in "出発地", with: "堺駅"
    fill_in "目的地", with: "なんば駅"
    select "帰り", from: "ルート区分"
    fill_in "メモ", with: "編集後のメモ"

    click_button "更新する"

    # 更新結果を確認
    assert_text "いつもの移動を更新しました"
    assert_text "通勤ルート"
    assert_text "堺駅"
    assert_text "なんば駅"
    assert_text "編集後のメモ"
  end

  test "登録したルートを削除できる" do
    # ユーザー登録
    visit new_user_path

    fill_in "名前", with: "削除テスト太郎"
    fill_in "メールアドレス", with: "delete-test@example.com"
    fill_in "パスワード", with: "password"
    fill_in "パスワード確認", with: "password"

    click_button "登録する"

    assert_text "ユーザー登録が完了しました"
    assert_current_path root_path

    # ログイン
    visit new_session_path

    fill_in "メールアドレス", with: "delete-test@example.com"
    fill_in "パスワード", with: "password"

    click_button "ログイン"

    assert_text "ログインしました"
    assert_current_path root_path

    # ルート登録
    visit new_usual_route_path

    fill_in "ルート名", with: "削除するルート"
    fill_in "出発地", with: "堺"
    fill_in "目的地", with: "梅田"
    select "行き", from: "ルート区分"
    fill_in "メモ", with: "削除テスト用"

    click_button "登録する"

    assert_text "いつもの移動を登録しました"

    # ルート詳細へ移動
    click_link "ルート一覧を見る"
    click_link "削除するルート"

    assert_text "ルート詳細"
    assert_text "削除するルート"

    # 確認ダイアログを承認して削除
    accept_confirm "このルートを削除しますか？" do
      click_button "削除する"
    end

    # 削除結果を確認
    assert_text "いつもの移動を削除しました"
    assert_no_text "削除するルート"
  end

  test "他のユーザーのルートにはアクセスできない" do
    # テストユーザー1でログイン
    visit new_session_path

    fill_in "メールアドレス", with: users(:one).email
    fill_in "パスワード", with: "password"

    click_button "ログイン"

    assert_text "ログインしました"
    assert_current_path root_path

    # テストユーザー2が所有するルートへ直接アクセス
    visit usual_route_path(usual_routes(:two))

    # 404画面になることを確認
    assert_text "404"
    assert_text "ページが見つかりませんでした"

    # 他ユーザーのルート情報が表示されないことを確認
    assert_no_text "通学ルート"
    assert_no_text "学校前"
    assert_no_text "難波駅"
  end

  test "現在時刻に応じた次の便が表示される" do
    travel_to Time.zone.local(2026, 9, 25, 8, 0, 0) do
      # ユーザー登録
      visit new_user_path

      fill_in "名前", with: "次の便テスト太郎"
      fill_in "メールアドレス", with: "next-bus-test@example.com"
      fill_in "パスワード", with: "password"
      fill_in "パスワード確認", with: "password"

      click_button "登録する"

      assert_text "ユーザー登録が完了しました"
      assert_current_path root_path

      # ログイン
      visit new_session_path

      fill_in "メールアドレス", with: "next-bus-test@example.com"
      fill_in "パスワード", with: "password"

      click_button "ログイン"

      assert_text "ログインしました"
      assert_current_path root_path

      # ルート登録
      visit new_usual_route_path

      fill_in "ルート名", with: "朝の通勤"
      fill_in "出発地", with: "堺"
      fill_in "目的地", with: "難波"
      select "行き", from: "ルート区分"

      click_button "登録する"

      # ルート詳細へ移動
      click_link "ルート一覧を見る"
      click_link "朝の通勤"

      # 平日の時刻表を登録
      click_link "時刻表を登録する", match: :first

      select "平日", from: "曜日区分"
      all("input[type='time']").first.fill_in(with: "08:30")
      all(".timetable-form__departure input[type='text']").first.fill_in(with: "快速")

      click_button "登録する"

      # 08:00現在、次の便が08:30であることを確認
      assert_text "次の出発"
      assert_text "08:30"
      assert_text "あと30分"
      assert_text "快速"
    end
  end
end
