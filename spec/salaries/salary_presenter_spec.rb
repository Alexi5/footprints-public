# encoding: utf-8
require 'spec_helper'
require 'salaries/salary_presenter'

describe SalaryPresenter do
  Salary = Struct.new(:id, :duration, :location, :amount)

  let(:salaries) do
    chicago_salary = Salary.new(1, 3, 'Chicago', 300)
    london_salary = Salary.new(2, 4, 'London', 400)

    [chicago_salary, london_salary]
  end

  let(:multiple_salaries) do
    [
      Salary.new(4, 5, "Chicago", 500),
      Salary.new(2, 3, "London",  600),
      Salary.new(1, 3, "Chicago", 300),
      Salary.new(3, 4, "Chicago", 400),
      Salary.new(5, 4, "London",  800),
      Salary.new(6, 5, "London",  1000)
    ]
  end

  let(:alphabetical_salaries) do
    [
      Salary.new(4, 5, "c", 500),
      Salary.new(2, 3, "b",  600),
      Salary.new(1, 3, "a", 300),
    ]
  end

  it 'gets the currency symbol for a location' do
    presenter = SalaryPresenter.new(salaries)
    expect(presenter.currency_symbol("Chicago")).to eq('$')
    expect(presenter.currency_symbol('London')).to eq('£')
  end

  it 'organizes monthly salaries by location' do
    presenter = SalaryPresenter.new(salaries)
    expect(presenter.monthly_salaries_by_location("Chicago")).to eq([[1, 3, "300.00"]])
    expect(presenter.monthly_salaries_by_location("London")).to eq([[2, 4, "400.00"]])
  end

  it 'organizes multiple monthly salaries by location' do
    presenter = SalaryPresenter.new(multiple_salaries)
    expect(presenter.monthly_salaries_by_location("Chicago")).to eq([[1, 3, "300.00"], [3, 4, "400.00"], [4, 5, "500.00"]])
    expect(presenter.monthly_salaries_by_location("London")).to eq([[2, 3, "600.00"], [5, 4, "800.00"], [6, 5, "1000.00"]])
  end

  it 'organizes annual salaries by location' do
    salaries_by_location = { "Chicago" => "300.00",
                             "London"  => "400.00" }
    presenter = SalaryPresenter.new([], salaries)
    expect(presenter.annual_salaries_by_location).to eq(salaries_by_location)
  end

  it 'organizes monthly salaries by alphabetical order of location' do
    presenter = SalaryPresenter.new(alphabetical_salaries, [])
    expect(presenter.locations).to eq(['a', 'b', 'c'])
  end
end
