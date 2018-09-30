require 'repository'
require 'applicants/applicant_archiver'

namespace :db do
  desc "Destroys Everything from Databases"
  task :destroy_all => :environment do
    puts "Destroying Everything"
    Footprints::Repository.applicant.destroy_all
    Footprints::Repository.message.destroy_all
    Footprints::Repository.craftsman.destroy_all
  end

  desc "Archives applicants if they have been neglected for at least three months"
  task :archive_applicants => :environment do
    puts "Archiving neglected applicants"
    Footprints::ApplicantArchiver.archive_neglected_applicants
  end

  desc "Expires assigned craftsman records after 10 days"
  task :expire_assigned_craftsman_records => :environment do
    puts "Expiring assigned craftsman records"
    Footprints::ApplicantDispatch::RecordManager.expire_assigned_craftsman_records
  end

  desc "Add default salary records for Chicago, London, Los Angeles"
  task :salary_setup => :environment do
    puts "Building salary records"
    (3..12).each do |months|
      Footprints::Repository.monthly_apprentice_salary.create({:location => "Chicago", :duration => months, :amount => 0.00})
      Footprints::Repository.monthly_apprentice_salary.create({:location => "London", :duration => months, :amount => 0.00})
      Footprints::Repository.monthly_apprentice_salary.create({:location => "Los Angeles", :duration => months, :amount => 0.00})
    end
    Footprints::Repository.annual_starting_craftsman_salary.create({:location => "Chicago", :amount => 0.00})
    Footprints::Repository.annual_starting_craftsman_salary.create({:location => "London", :amount => 0.00})
    Footprints::Repository.annual_starting_craftsman_salary.create({:location => "Los Angeles", :amount => 0.00})
  end

  desc "Add default salary records for Los Angeles"
  task :salary_setup_los_angeles => :environment do
    puts "Building salary records for Los Angeles"
    (3..12).each do |months|
      Footprints::Repository.monthly_apprentice_salary.create({:location => "Los Angeles", :duration => months, :amount => 0.00})
    end
    Footprints::Repository.annual_starting_craftsman_salary.create({:location => "Los Angeles", :amount => 0.00})
  end
end
