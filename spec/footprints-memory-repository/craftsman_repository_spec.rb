require 'spec_helper'
require 'memory_repository/applicant_repository'
require './spec/footprints/shared_examples/craftsman_examples'

describe MemoryRepository::CraftsmanRepository do
  it_behaves_like "craftsman repository"

  let(:repo) { described_class.new }
   let(:attrs) {{
    :name => "test craftsman",
    :status => "test status",
    :employment_id => "123"
  }}

  let(:craftsman) { repo.create(attrs) }

  it "orders craftsman asc" do
    craftsman
    test = repo.create(:name => "abc", :status => "ok", :employment_id => "789")
    repo.order("name ASC").first.should == test.id
  end

  it "orders craftsman desc" do
    repo.create(attrs)
    test = repo.create(:name => "xyz", :status => "ok", :employment_id => "456")
    repo.order("name DESC").first.should == test.id
  end
end


