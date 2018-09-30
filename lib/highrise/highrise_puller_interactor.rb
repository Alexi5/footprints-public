require 'repository'
require 'highrise'
module Interactor
  class HighrisePuller

    def initialize
      @repo = Footprints::Repository
      @last_six_months_applicants ||=  Highrise::Recording.find_all_across_pages_since(Time.now - 6.months).select { |r|
        r.respond_to?(:title) && r.title == "ABC, Inc. Apprenticeship Application" }
    end

    def get_applications(time)
      if time == Time.now - 6.months
        @last_six_months_applicants
      else
        Highrise::Recording.find_all_across_pages_since(time).select do |r|
          r.respond_to?(:title) && r.title == "ABC, Inc. Apprenticeship Application"
        end
      end
    end

    def sync_unadded_applicants
      initial_applications = get_applications(Time.now - 4.hours)
      puts "Found #{initial_applications.count} applications"
      create_applicants(initial_applications)
    end

    def sync_applicants_now(minute)
      applications = get_applications(Time.now - minute.minutes)
      puts "Found #{applications.count} applications"
      create_applicants(applications)
    end

    def create_applicants(applications)
      applications.each do |app|
        if @repo.applicant.find_by_email(get_email(app.body))
          puts "#{app.subject_name} already exists in the database"
        else
          applicant_data = {}
          applicant_answers = get_information(app.body)
          applicant_data[:name] = app.subject_name
          applicant_data[:applied_on] = (app.created_at.in_time_zone).to_date
          applicant_data[:email] = get_email(app.body)
          applicant_data[:url] = get_url(app.body)
          applicant_data[:about] = remove_quotes(applicant_answers[0][0])
          applicant_data[:software_interest] = remove_quotes(applicant_answers[1][0])
          applicant_data[:reason] = remove_quotes(applicant_answers[2][0])
          applicant_data[:discipline] = get_discipline(app.body)
          applicant_data[:skill] = get_skill_level(app.body)
          applicant_data[:location] = app.location
          @repo.applicant.create(applicant_data)
        end
      end
    end

    def remove_quotes(info)
      info.delete("\\")
    end

    def create_applicants_from_highrise(time = Time.now - 1.month)
      two_weeks_applicants = get_applications(time)
      create_applicants(two_weeks_applicants)
    end

    def get_email(body)
      email = body.match(/(?<=\nEmail:)(.*?)(?=\n)/)
      email[0].strip
    end

    def get_answers(body)
      body.scan(/(?<=\nA:.{2})(.*?)(?=\"\n)/m)
    end

    def get_information(body)
      information = get_answers(body)
      information << get_url(body)
      information
    end

    def get_url(body)
      url = body.match(/(?<=\nPublication:)(.*?)(?=\n)/m)
      url[0].strip
    end

    def get_discipline(body)
      if body.include?("what do you love about writing software?")
        "software"
      else
        "design"
      end
    end

    def get_skill_level(body)
      body.match(/(?<=why do you want to be a\(n\)\s)(.*?)(?=\sat)/)[0]
    end

    def get_all_recent_applicants
      app_hash = {}
      applicants = @repo.applicant.where("id", "not null")
      applicants.each do |app|
        if app.applied_on > Date.parse("20131101")
          app_hash[app.id] = app.name
        end
      end
      app_hash
    end

    def get_messages_for_applicants(time)
      recent = get_all_recent_applicants
      msg_count = 0
      messages = Highrise::Recording.find_all_across_pages_since(time).select { |r| r.respond_to?(:title) && (r.title == "ABC, Inc. Apprenticeship" || r.title == "Re: ABC, Inc. Apprenticeship")}
      recent.each_pair do |id, name|
        message = messages.select { |r| r.respond_to?(:subject_name) && r.subject_name.downcase == name.downcase }
        msg_count += message.length
        recent[id] = message
        p message
      end
      puts "Found #{msg_count} new messages"
      recent
    end

    def get_current_messages(time)
      messages = get_messages_for_applicants(time)
      populate_messages(messages)
    end

    def populate_messages(messages)
      messages.each_pair do |app_id, message_array|
        message_array.each do |msg|
          puts "the message #{msg}"
          puts "the body #{msg.body}"
          puts "the id #{app_id}"
          puts "the person #{@repo.applicant.find(app_id)}"
          @repo.message.create({
            :title => msg.title,
            :body => msg.body,
            :created_at => (msg.created_at.in_time_zone).to_date,
            :applicant_id => app_id
          })
        end
      end
    end
  end
end
