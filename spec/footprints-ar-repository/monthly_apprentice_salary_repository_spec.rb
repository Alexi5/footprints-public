require 'spec_helper'
require 'ar_repository/monthly_apprentice_salary_repository'
require './spec/footprints/shared_examples/monthly_apprentice_salary_examples'

describe ArRepository::MonthlyApprenticeSalaryRepository do
  it_behaves_like "monthly apprentice salary"
end
