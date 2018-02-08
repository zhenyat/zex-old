require "application_system_test_case"

class PairsTest < ApplicationSystemTestCase
  setup do
    @pair = pairs(:one)
  end

  test "visiting the index" do
    visit pairs_url
    assert_selector "h1", text: "Pairs"
  end

  test "creating a Pair" do
    visit pairs_url
    click_on "New Pair"

    fill_in "Base", with: @pair.base_id
    fill_in "Code", with: @pair.code
    fill_in "Decimal Places", with: @pair.decimal_places
    fill_in "Fee", with: @pair.fee
    fill_in "Hidden", with: @pair.hidden
    fill_in "Max Price", with: @pair.max_price
    fill_in "Min Amount", with: @pair.min_amount
    fill_in "Min Price", with: @pair.min_price
    fill_in "Name", with: @pair.name
    fill_in "Quote", with: @pair.quote_id
    fill_in "Status", with: @pair.status
    click_on "Create Pair"

    assert_text "Pair was successfully created"
    click_on "Back"
  end

  test "updating a Pair" do
    visit pairs_url
    click_on "Edit", match: :first

    fill_in "Base", with: @pair.base_id
    fill_in "Code", with: @pair.code
    fill_in "Decimal Places", with: @pair.decimal_places
    fill_in "Fee", with: @pair.fee
    fill_in "Hidden", with: @pair.hidden
    fill_in "Max Price", with: @pair.max_price
    fill_in "Min Amount", with: @pair.min_amount
    fill_in "Min Price", with: @pair.min_price
    fill_in "Name", with: @pair.name
    fill_in "Quote", with: @pair.quote_id
    fill_in "Status", with: @pair.status
    click_on "Update Pair"

    assert_text "Pair was successfully updated"
    click_on "Back"
  end

  test "destroying a Pair" do
    visit pairs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Pair was successfully destroyed"
  end
end
