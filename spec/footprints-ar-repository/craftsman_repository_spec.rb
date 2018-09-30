require 'spec_helper'
require "ar_repository/craftsman_repository"
require "./spec/footprints/shared_examples/craftsman_examples.rb"

describe ArRepository::CraftsmanRepository do
  it_behaves_like "craftsman repository"

  let(:repo) { described_class.new }
  let(:attrs) {{
    :name => "test craftsman",
    :status => "test status"
  }}

  let(:craftsman) { repo.create(attrs) }

  it "orders craftsman" do
    test = repo.create(:name => "abc", :status => "ok", :employment_id => "123")
    repo.order("name ASC").first.should == test
  end
end
