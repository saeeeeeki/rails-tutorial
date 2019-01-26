require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # 無効な送信
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    # 有効な送信
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content, picture: picture } }
    end
    assert_redirected_to root_url
    assert assigns(:micropost).picture?
    follow_redirect!
    assert_match content, response.body
    # 投稿を削除する
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # 違うユーザーのプロフィールにアクセス (削除リンクがないことを確認)
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  test "microposts reply" do
    following = users(:lana)
    unfollowing = users(:archer)

    # can see following user's post and reply to me
    log_in_as(following)
    get root_path
    post microposts_path, params: { micropost: { content: "following user's posted" } }
    follow_redirect!
    post microposts_path, params: { micropost: { content: "test posted to @michael_example !!" } }

    log_in_as(@user)
    get root_path
    assert_match CGI.escapeHTML("following user's posted"), response.body
    assert_match CGI.escapeHTML("test posted to @michael_example !!"), response.body

    # can't see following user's reply to other user
    log_in_as(following)
    get root_path
    post microposts_path, params: { micropost: { content: "test posted to @sterling_archer !!" } }

    log_in_as(@user)
    get root_path
    assert_no_match CGI.escapeHTML("test posted to @sterling_archer !!"), response.body

    # can see own reply to other user
    post microposts_path, params: { micropost: { content: "test posted to @example_1 !!" } }
    follow_redirect!
    assert_match CGI.escapeHTML("test posted to @example_1 !!"), response.body

    # can see unfollowing user reply to me
    log_in_as(unfollowing)
    get root_path
    post microposts_path, params: { micropost: { content: "test posted to @michael_example !!" } }

    log_in_as(@user)
    get root_path
    assert_match CGI.escapeHTML("test posted to @michael_example !!"), response.body

    # can't see unfollowing user's post
    log_in_as(unfollowing)
    get root_path
    post microposts_path, params: { micropost: { content: "unfollowing user's posted" } }

    log_in_as(@user)
    get root_path
    assert_no_match CGI.escapeHTML("unfollowing user's posted"), response.body
  end
end
