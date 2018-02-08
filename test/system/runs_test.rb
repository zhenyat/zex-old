require "application_system_test_case"

class RunsTest < ApplicationSystemTestCase
  setup do
    @run = runs(:one)
  end

  test "visiting the index" do
    visit runs_url
    assert_selector "h1", text: "Runs"
  end

  test "creating a Run" do
    visit runs_url
    click_on "New Run"

    fill_in "Depo", with: @run.depo
    fill_in "Kind", with: @run.kind
    fill_in "Last", with: @run.last
    fill_in "Martingale", with: @run.martingale
    fill_in "Orders", with: @run.orders
    fill_in "Overlay", with: @run.overlay
    fill_in "Pair", with: @run.pair_id
    fill_in "Profit", with: @run.profit
    fill_in "Scale", with: @run.scale
    fill_in "Start", with: @run.start
    fill_in "Status", with: @run.status
    fill_in "Stop Loss", with: @run.stop_loss
    click_on "Create Run"

    assert_text "Run was successfully created"
    click_on "Back"
  end

  test "updating a Run" do
    visit runs_url
    click_on "Edit", match: :first

    fill_in "Depo", with: @run.depo
    fill_in "Kind", with: @run.kind
    fill_in "Last", with: @run.last
    fill_in "Martingale", with: @run.martingale
    fill_in "Orders", with: @run.orders
    fill_in "Overlay", with: @run.overlay
    fill_in "Pair", with: @run.pair_id
    fill_in "Profit", with: @run.profit
    fill_in "Scale", with: @run.scale
    fill_in "Start", with: @run.start
    fill_in "Status", with: @run.status
    fill_in "Stop Loss", with: @run.stop_loss
    click_on "Update Run"

    assert_text "Run was successfully updated"
    click_on "Back"
  end

  test "destroying a Run" do
    visit runs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Run was successfully destroyed"
  end
end
