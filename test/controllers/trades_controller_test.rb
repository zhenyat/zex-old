require 'test_helper'

class TradesControllerTest < ActionDispatch::IntegrationTest
  test "should get candlesticks" do
    get trades_candlesticks_url
    assert_response :success
  end

  test "should get create_cash" do
    get trades_create_cash_url
    assert_response :success
  end

  test "should get index" do
    get trades_index_url
    assert_response :success
  end

  test "should get order_book" do
    get trades_order_book_url
    assert_response :success
  end

  test "should get update_cash" do
    get trades_update_cash_url
    assert_response :success
  end

end
