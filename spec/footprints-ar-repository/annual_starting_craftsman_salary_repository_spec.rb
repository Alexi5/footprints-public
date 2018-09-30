require 'spec_helper'
require 'ar_repository/annual_starting_craftsman_salary_repository'
require './spec/footprints/shared_examples/annual_starting_craftsman_salary_examples'

describe ArRepository::AnnualStartingCraftsmanSalaryRepository do
  it_behaves_like "annual starting craftsman salary"
end
