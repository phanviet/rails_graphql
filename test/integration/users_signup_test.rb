require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test 'invalid signup information' do
    get signup_path
    
    assert_no_difference 'User.count' do
      post users_path, params: {
        user: {
          name: '',
          email: 'user@invalid',
          password: 'foo',
          password_confirmation: 'bar'
        }
      }
    end
    
    assert_template 'users/new'
    assert_select '#error_explanation'
  end
  
  test 'valid signup information' do
    get signup_path
    
    assert_difference 'User.count', 1 do
      post users_path, params: {
        user: {
          name: 'Phan Hong Viet',
          email: 'vietexample@example.com',
          password: 'foobar123',
          password_confirmation: 'foobar123',
        }
      }
    end
    
    follow_redirect!
    
    assert_template 'users/show'
  end
end
