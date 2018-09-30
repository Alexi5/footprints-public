module Footprints

  # Reminder is an emailer service that sends emails about applicants still in
  # the pipeline.
  class Reminder
    class << self

      def notify_craftsman_of_outstanding_requests
        Applicant.not_archived.each do |applicant|
          mail_craftsman(applicant) if applicant.outstanding?(1)
          mail_steward(applicant) if steward_needs_notification?(applicant)
        end
      end

      def mail_craftsman(applicant)
        NotificationMailer.craftsman_reminder(applicant).deliver
        Notification.create(:applicant => applicant, :craftsman => applicant.craftsman)
      end

      def mail_steward(applicant)
        NotificationMailer.steward_reminder(applicant).deliver
        Notification.create(:applicant => applicant, :craftsman => @steward)
      end

      def steward_needs_notification?(applicant)
        applicant.outstanding?(2) && !steward_notified?(applicant)
      end

      def steward_notified?(applicant)
        @steward = Craftsman.find_by_email(ENV["STEWARD"])
        Notification.where(:applicant => applicant, :craftsman => @steward).present?
      end

    end
  end

end
