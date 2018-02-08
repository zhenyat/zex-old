require 'test_helper'

class PairsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pair = pairs(:one)
  end

  test "should get index" do
    get pairs_url
    assert_response :success
  end

  test "should get new" do
    get new_pair_url
    assert_response :success
  end

  test "should create pair" do
    assert_difference('Pair.count') do
      post pairs_url, params: { pair: { base_id: @pair.base_id, code: @pair.code, decimal_places: @pair.decimal_places, fee: @pair.fee, hidden: @pair.hidden, max_price: @pair.max_price, min_amount: @pair.min_amount, min_price: @pair.min_price, name: @pair.name, quote_id: @pair.quote_id, status: @pair.status } }
    end

    assert_redirected_to pair_url(Pair.last)
  end

  test "should show pair" do
    get pair_url(@pair)
    assert_response :success
  end

  test "should get edit" do
    get edit_pair_url(@pair)
    assert_response :success
  end

  test "should update pair" do
    patch pair_url(@pair), params: { pair: { base_id: @pair.base_id, code: @pair.code, decimal_places: @pair.decimal_places, fee: @pair.fee, hidden: @pair.hidden, max_price: @pair.max_price, min_amount: @pair.min_amount, min_price: @pair.min_price, name: @pair.name, quote_id: @pair.quote_id, status: @pair.status } }
    assert_redirected_to pair_url(@pair)
  end

  test "should destroy pair" do
    assert_difference('Pair.count', -1) do
      delete pair_url(@pair)
    end

    assert_redirected_to pairs_url
  end
end
