require "spec_helper"
require "craftsmen/craftsmen_presenter"
require 'craftsmen/skills'

describe CraftsmenPresenter do
  before :each do
    @repo = Footprints::Repository.craftsman
    @seeking_resident_apprentice = @repo.create(name: "Test", employment_id: "1", email: "test@abcinc.com", seeking: true, skill: Skills.get_key_for_skill("Resident"))
    @seeking_student_apprentice  = @repo.create(name: "Test", employment_id: "2", email: "test@abcinc.com", seeking: true, skill: Skills.get_key_for_skill("Student"))
  end

  after :each do
    Footprints::Repository.craftsman.destroy_all
  end

  it "returns all craftsmen seeking a resident apprentice" do
    presenter = CraftsmenPresenter.new(@repo)
    presenter.seeking_resident_apprentice.first.should == @seeking_resident_apprentice
  end

  it "returns all craftsmen seeking a student apprentice" do
    presenter = CraftsmenPresenter.new(@repo)
    presenter.seeking_student_apprentice.first.should == @seeking_student_apprentice
  end
end
