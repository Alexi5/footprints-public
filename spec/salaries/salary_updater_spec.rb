require 'spec_helper'
require 'salaries/salary_updater'

describe SalaryUpdater do
  def create_monthly_salaries
    ["Chicago", "London"].each do |location|
      (3..6).each do |duration|
        Footprints::Repository.monthly_apprentice_salary.create( duration: duration, location: location, amount: duration * 100 )
      end
    end
  end

  def create_annual_salaries
    ["Chicago", "London"].each do |location|
      Footprints::Repository.annual_starting_craftsman_salary.create(location: location, amount: 12345.0 )
    end
  end


  before :each do
    create_monthly_salaries
    create_annual_salaries
  end

  after :each do
    Footprints::Repository.monthly_apprentice_salary.destroy_all
    Footprints::Repository.annual_starting_craftsman_salary.destroy_all
  end

  it "creates a monthly salary" do
    params = {"location" => "Chicago", "duration" => "15", "amount" => "500.0"}
    updater = SalaryUpdater.new(params)
    updater.create_monthly

    expect(Footprints::Repository.monthly_apprentice_salary.last.amount).to eq(500.0)
  end


  it "parses the params hash" do
    params = {"monthly" => {"Chicago" => {"3" => "333.0", "4" => "444.0"}, "London" => {"5" => "555.0", "6" => "666.0"}},
              "annual" => {"Chicago" => "54321.0", "London" => "98765.0"}}

    updater = SalaryUpdater.new(params)
    updater.update
    expect(Footprints::Repository.monthly_apprentice_salary.find_by_duration_at_location(3, "Chicago").amount).to eq(333.0)
    expect(Footprints::Repository.monthly_apprentice_salary.find_by_duration_at_location(4, "Chicago").amount).to eq(444.0)
    expect(Footprints::Repository.monthly_apprentice_salary.find_by_duration_at_location(5, "London").amount).to eq(555.0)
    expect(Footprints::Repository.monthly_apprentice_salary.find_by_duration_at_location(6, "London").amount).to eq(666.0)
    expect(Footprints::Repository.annual_starting_craftsman_salary.find_by_location("Chicago").amount).to eq(54321.0)
    expect(Footprints::Repository.annual_starting_craftsman_salary.find_by_location("London").amount).to eq(98765.0)
  end

  it "accepts various non-integer input and sets amounts accordingly" do
    params = {"monthly" => {"Chicago" => {"3" => "USD 333", "4" => "$444"}, "London" => {"5" => "5,000", "6" => "666.0"}},
              "annual" => {"Chicago" => "$54,321.00", "London" => "98,765"}}

    updater = SalaryUpdater.new(params)
    updater.update
    expect(Footprints::Repository.monthly_apprentice_salary.find_by_duration_at_location(3, "Chicago").amount).to eq(333.0)
    expect(Footprints::Repository.monthly_apprentice_salary.find_by_duration_at_location(4, "Chicago").amount).to eq(444.0)
    expect(Footprints::Repository.monthly_apprentice_salary.find_by_duration_at_location(5, "London").amount).to eq(5000.0)
    expect(Footprints::Repository.monthly_apprentice_salary.find_by_duration_at_location(6, "London").amount).to eq(666.0)
    expect(Footprints::Repository.annual_starting_craftsman_salary.find_by_location("Chicago").amount).to eq(54321.0)
    expect(Footprints::Repository.annual_starting_craftsman_salary.find_by_location("London").amount).to eq(98765.0)
  end

  context '#destroy' do
    it 'deletes a salary record' do
      salary = create_salary
      updater = SalaryUpdater.new({"id" => salary.id})
      updater.destroy

      expect(Footprints::Repository.monthly_apprentice_salary.find_by_id(salary.id)).to eq nil
    end

    def create_salary
      params = {"location" => "Chicago", "duration" => "15", "amount" => "500.0"}
      updater = SalaryUpdater.new(params)
      updater.create_monthly
    end
  end
end
