require 'test_helper'

class RunsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @run = runs(:one)
  end

  test "should get index" do
    get runs_url
    assert_response :success
  end

  test "should get new" do
    get new_run_url
    assert_response :success
  end

  test "should create run" do
    assert_difference('Run.count') do
      post runs_url, params: { run: { depo: @run.depo, kind: @run.kind, last: @run.last, martingale: @run.martingale, orders: @run.orders, overlay: @run.overlay, pair_id: @run.pair_id, profit: @run.profit, scale: @run.scale, start: @run.start, status: @run.status, stop_loss: @run.stop_loss } }
    end

    assert_redirected_to run_url(Run.last)
  end

  test "should show run" do
    get run_url(@run)
    assert_response :success
  end

  test "should get edit" do
    get edit_run_url(@run)
    assert_response :success
  end

  test "should update run" do
    patch run_url(@run), params: { run: { depo: @run.depo, kind: @run.kind, last: @run.last, martingale: @run.martingale, orders: @run.orders, overlay: @run.overlay, pair_id: @run.pair_id, profit: @run.profit, scale: @run.scale, start: @run.start, status: @run.status, stop_loss: @run.stop_loss } }
    assert_redirected_to run_url(@run)
  end

  test "should destroy run" do
    assert_difference('Run.count', -1) do
      delete run_url(@run)
    end

    assert_redirected_to runs_url
  end
end
