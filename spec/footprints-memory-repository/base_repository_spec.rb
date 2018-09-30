require 'spec_helper'
require 'memory_repository/base_repository'
require 'ostruct'

describe MemoryRepository do
  class TestRepository
    extend MemoryRepository::BaseRepository
  end

  describe TestRepository do
    let(:object) { OpenStruct.new(:id => nil, :name => "test") }
    let(:repo) { TestRepository }

    before { repo.destroy_all }

    context ".save" do
      it "saves to the database and sets ID" do
        object.id.should be_nil
        saved = repo.save(object)

        saved.id.should_not be_nil
        saved.name.should == object.name
      end

      it "increments the id for each object" do
        object2 = OpenStruct.new(:id => nil, :name => "test2")
        saved1 = repo.save(object)
        saved2 = repo.save(object2)

        saved2.id.should > saved1.id
      end

      it "doesnt reuse existing id" do
        object.id = 1
        repo.save(object)
        object.id.should == 1
      end

      it "updates attrs for an existing record" do
        saved = repo.save(object)
        saved.name = "New Name"
        repo.save(saved)
        found = repo.find(saved.id)
        found.name.should == "New Name"
      end
    end

    context ".find" do
      it "finds object by id" do
        saved = repo.save(object)
        repo.find(saved.id).should == saved
      end
    end

    context "delete" do
      it "deletes an object by id" do
        saved = repo.save(object)
        repo.delete(saved.id).should be_true
      end
    end
  end
end
