require "application_system_test_case"

class PatternsTest < ApplicationSystemTestCase
  setup do
    @pattern = patterns(:one)
  end

  test "visiting the index" do
    visit patterns_url
    assert_selector "h1", text: "Patterns"
  end

  test "creating a Pattern" do
    visit patterns_url
    click_on "New Pattern"

    fill_in "Avatar", with: @pattern.avatar
    fill_in "Description", with: @pattern.description
    fill_in "Mix", with: @pattern.mix
    fill_in "Name", with: @pattern.name
    fill_in "Status", with: @pattern.status
    fill_in "Title", with: @pattern.title
    click_on "Create Pattern"

    assert_text "Pattern was successfully created"
    click_on "Back"
  end

  test "updating a Pattern" do
    visit patterns_url
    click_on "Edit", match: :first

    fill_in "Avatar", with: @pattern.avatar
    fill_in "Description", with: @pattern.description
    fill_in "Mix", with: @pattern.mix
    fill_in "Name", with: @pattern.name
    fill_in "Status", with: @pattern.status
    fill_in "Title", with: @pattern.title
    click_on "Update Pattern"

    assert_text "Pattern was successfully updated"
    click_on "Back"
  end

  test "destroying a Pattern" do
    visit patterns_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Pattern was successfully destroyed"
  end
end
