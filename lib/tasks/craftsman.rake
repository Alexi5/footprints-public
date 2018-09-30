require 'repository'

namespace :db do
  desc "Destroys all Craftsmen Records for Staging"
  task :destroy_craftsmen => :environment do
  end

  desc "Syncs Craftsmen List from Doppler"
  task :sync_craftsmen => :environment do
  end
end

namespace :convert do
  desc "Converts user and notes craftsman_ids to use craftsman's employment id as foriegn key"
  task :craftsman_ids_to_employment_id => :environment do
    puts "Converting foreign keys for users and notes"
    Note.all.each do |note|
      craftsman = Craftsman.find_by_id(note.craftsman_id)
      note.craftsman_id = craftsman.employment_id.to_i rescue nil
      note.save!
    end

    User.all.each do |user|
      craftsman = Craftsman.find_by_id(user.craftsman_id)
      user.craftsman_id = craftsman.employment_id.to_i rescue nil
      user.save!
    end
  end
end

desc "Set default craftsman profile settings"
task :set_default_craftsman_profile_settings => :environment do
  puts "Setting all craftsman profile records to seeking: true and skill: resident"
  Craftsman.all.each do |craftsman|
    craftsman.seeking = true
    craftsman.skill = "Resident"
    craftsman.save!
  end
end
