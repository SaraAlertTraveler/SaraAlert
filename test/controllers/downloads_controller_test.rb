# frozen_string_literal: true

require 'test_case'

class DownloadsControllerTest < ActionController::TestCase
  test 'download' do
    user = create(:public_health_user)
    download = create(:download, user_id: user.id)
    text = StringIO.new('text')
    download.exports.attach(io: text, filename: 'text.txt', content_type: 'application/text')
    sign_in user
    get :download, params: { id: download.id }
    assert_response :success
  end

  test 'download signed out' do
    user = create(:public_health_user)
    download = create(:download, user_id: user.id)
    text = StringIO.new('text')
    download.exports.attach(io: text, filename: 'text.txt', content_type: 'application/text')
    get :download, params: { id: download.id }
    # Redirect to the sign_in page.
    assert_response :redirect
  end

  test 'download from a different user' do
    first_user = create(:public_health_user)
    download = create(:download, user_id: first_user.id)
    second_user = create(:public_health_user)
    text = StringIO.new('text')
    download.exports.attach(io: text, filename: 'text.txt', content_type: 'application/text')
    sign_in second_user
    get :download, params: { id: download.id }
    # Redirect to not found
    assert_response :redirect
  end

  test 'downloaded' do
    user = create(:public_health_user)
    download = create(:download, user_id: user.id)
    sign_in user

    assert_difference 'Download.count', -1 do
      post :downloaded, params: {
        id: download.id
      }
    end
  end
end
