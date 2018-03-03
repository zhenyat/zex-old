require 'test_helper'

class SelectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get selections_new_url
    assert_response :success
  end

  test "should get charts" do
    get selections_charts_url
    assert_response :success
  end

end
