require 'highrise/highrise_puller_interactor'
require 'repository'

namespace :db do
  desc "Destroys all messages"
  task :destroy_messages => :environment do
    puts "Destroying Messages from Database"
    Footprints::Repository.message.destroy_all
  end

  desc "Gets communication for applicants"
  task :get_new_messages => :environment do
    puts "Getting new messages for applicants"
    interactor = Interactor::HighrisePuller.new
    interactor.get_current_messages(Time.now - 4.hours)
  end

  desc "Populates messages for current applicants"
  task :populate_current_messages => :environment do
    puts "Getting messages for current applicants"
    interactor = Interactor::HighrisePuller.new
    interactor.get_current_messages(Time.now - 2.months)
  end
end
