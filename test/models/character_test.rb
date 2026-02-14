require "test_helper"

class CharacterTest < ActiveSupport::TestCase
  test "default entry character prefers Aristotle Onassis among lead characters" do
    onassis = Character.create!(name: "Aristotle Onassis", account: accounts(:one), lead_character: true)
    Character.create!(name: "Allen Dulles", account: accounts(:one), lead_character: true)

    assert_equal [ onassis.id ], Character.default_entry_character_ids
  end

  test "default entry character falls back to first lead when Aristotle Onassis is missing" do
    first_lead = Character.create!(name: "First Lead", account: accounts(:one), lead_character: true)
    Character.create!(name: "Second Lead", account: accounts(:one), lead_character: true)

    assert_equal [ first_lead.id ], Character.default_entry_character_ids
  end

  test "default entry character is empty when there are no lead characters" do
    assert_equal [], Character.default_entry_character_ids
  end
end
