require "spec_helper"
require 'notes/note_presenter'

describe NotePresenter do
  let(:given_time) { DateTime.parse("01 Jan 2000 12:00:00 -6") }
  let(:note) { Footprints::Repository.notes.create(:craftsman_id => 1, :applicant_id => 1, :body => "test", :updated_at => given_time) }
  describe "#updated_at" do
    it "formats the date and time" do
      expected_format = "12:00PM - 01/01/2000"
      expect(described_class.new(note).updated_at).to eq expected_format
    end
  end

  describe "#created_by?" do
    it "returns true if the user created the note" do
      user = double("user", :craftsman_id => 1)
      expect(described_class.new(note).created_by?(user)).to be_true
    end

    it "returns true if the user created the note" do
      user = double("user", :craftsman_id => 2)
      expect(described_class.new(note).created_by?(user)).to be_false
    end
  end
end
