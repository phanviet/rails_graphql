require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  setup do
    @user = users(:michael)
  end
  
  test 'micropost interface' do
    log_in_as(@user)
    get root_path
    assert_select '.pagination'
    assert_select 'input[type=file]'
    
    # Invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {
        micropost: {
          content: ''
        }
      }
    end
    
    assert_select '#error_explanation'
    
    # Valid submission
    content = 'This micropost really ties the room together'
    picture = fixture_file_upload('test/fixtures/files/rails.png', 'image/png')
    assert_difference 'Micropost.count' do
      post microposts_path, params: {
        micropost: {
          content: content,
          picture: picture
        }
      }
    end
    
    latest_post = Micropost.first
    assert latest_post.picture?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    
    # Delete post
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path first_micropost
    end
    
    # Visit different user (no delete links)
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end
  
end
