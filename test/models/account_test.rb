require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "default entry character uses configured main character" do
    account = accounts(:one)
    onassis = Character.create!(name: "Aristotle Onassis", account: account, lead_character: true)
    Character.create!(name: "Allen Dulles", account: account, lead_character: true)
    account.update!(main_character: onassis)

    assert_equal [ onassis.id ], account.default_entry_character_ids
  end

  test "default entry character falls back to lead character rules when main character is not set" do
    account = accounts(:one)
    onassis = Character.create!(name: "Aristotle Socrates Onassis", account: account, lead_character: true)
    Character.create!(name: "Allen Dulles", account: account, lead_character: true)

    assert_equal [ onassis.id ], account.default_entry_character_ids
  end

  test "main character must belong to the same account" do
    owner = User.create!(
      email: "other-owner@example.com",
      password: "password",
      password_confirmation: "password",
      skip_account_setup: true
    )
    other_account = Account.create!(name: "Other Timeline", owner: owner)
    other_character = Character.create!(name: "Other Person", account: other_account)
    account = accounts(:one)

    account.main_character = other_character

    assert_not account.valid?
    assert_includes account.errors[:main_character], "must belong to this timeline"
  end
end
