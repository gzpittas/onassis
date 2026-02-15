require "test_helper"

class AccountMembershipTest < ActiveSupport::TestCase
  test "member accounts appear in accessible accounts" do
    account = accounts(:one)
    editor = User.create!(
      email: "editor@example.com",
      password: "password",
      password_confirmation: "password",
      skip_account_setup: true
    )

    AccountMembership.create!(account: account, user: editor, role: "editor")

    assert_includes editor.accessible_accounts, account
  end

  test "role must be valid" do
    account = accounts(:one)
    editor = User.create!(
      email: "invalid-role@example.com",
      password: "password",
      password_confirmation: "password",
      skip_account_setup: true
    )

    assert_raises(ArgumentError) do
      AccountMembership.new(account: account, user: editor, role: "nope")
    end
  end
end
