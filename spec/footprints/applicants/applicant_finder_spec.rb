require 'spec_helper'
require 'applicants/applicant_finder'

module Footprints
  describe ApplicantFinder do
    let(:repo) { Footprints::Repository.applicant }
    let(:finder) { ApplicantFinder.new }

    before :all do
      Repository.register_repo(MemoryRepository)
    end

    after :all do
      Repository.register_repo(ArRepository)
    end

    def create_applicant(attrs={})
      defaults = {name: "Foo Bar", applied_on: Date.today}
      repo.create(defaults.merge(attrs))
    end

    context "applicant index params" do
      let!(:hello_world_applicant) { create_applicant(name: "Hello World") }
      let!(:reviewed_on_applicant) { create_applicant(reviewed_on: Date.today) }
      let!(:archived_applicant) { create_applicant(archived: true) }

      after do
        repo.destroy_all
      end

      it "gets applicants that are archived" do
        archived = finder.get_applicants({"status" => "archived"})

        expect(archived.size).to eq 1
        expect(archived.first).to eq archived_applicant
      end

      it "gets applicants by search" do
        expect(finder.get_applicants({"term" => "Hello"}).first).to eq hello_world_applicant
      end

      it "doesn't return applicants where archived is true" do
       expect(finder.get_applicants({"status" => "all"}).count).to eq 2
      end

      it "returns all applicants when status is unsupported" do
        expect(finder.get_applicants({"status" => "foobar"}).count).to eq 2
      end
    end
  end
end
