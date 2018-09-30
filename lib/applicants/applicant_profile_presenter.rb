require "./app/validators/url_validator"
require "argon/applicant_offer_letter_generator"

class ApplicantProfilePresenter
  include ApplicantsHelper

  def initialize(applicant)
    @applicant = applicant
    @validator = UrlValidator.new
  end

  def offer_text
    if applied_as_student?
      "Student Apprentice Contract"
    else
      "Extend Offer"
    end
  end

  def has_background?
    @applicant.codeschool.present? && @applicant.codeschool != "None" ||
    @applicant.college_degree.present? ||
    @applicant.cs_degree.present? ||
    @applicant.worked_as_dev.present?
  end

  def has_application_questions?
    @applicant.about != nil || @applicant.software_interest != nil || @applicant.reason != nil
  end

  def display_body(body)
    body.gsub(/\n/, '<br/>').delete("\\").delete("---").html_safe
  end

  def current_state(app = @applicant)
    state = ApplicantStateMachine.determine_state(app)
    DISPLAY_STATES[state]["current"]
  end

  def recent_interaction
    state = ApplicantStateMachine.determine_state(@applicant)
    format_date(@applicant.send(state))
  end

  def interactions
    interactions_list.reduce({}) do |interactions, interaction_type|
      add_interaction(interactions, interaction_type) if @applicant.send(interaction_type)
      interactions
    end
  end

  def url
    formatted_urls = []
    url = normalize_url(@applicant.url)
    url.each do |link|
      if @validator.valid_url?(link)
        formatted_urls << link
      elsif url_needs_http_prefix?(link)
        formatted_urls << "http://" + link
      end
    end
    formatted_urls
  end

  def applicant_hired?
    @applicant.hired == "yes"
  end

  def applicant_ready_for_hire?
    @applicant.start_date != nil && @applicant.end_date != nil
  end

  def can_be_unarchived?
    @applicant.archived == true && applicant_hired? == false
  end

  def hire_action
    if applicant_hired?
      "Hired"
    elsif applicant_ready_for_hire?
      "<a href='#' class='decision_made_on button primary'>Hire</a>"
    end
  end

  def waiting_state(app)
    state = ApplicantStateMachine.determine_state(app)
    DISPLAY_STATES[state]["waiting"]
  end

  def waiting_state_class(app)
    state = ApplicantStateMachine.determine_state(app)
    if app.archived
      "folder-open-o"
    else
      DISPLAY_STATES[state]["court"]
    end
  end

  def skill(applicant)
    applicant.skill.try(:capitalize)
  end

  def discipline(applicant)
    applicant.discipline.try(:capitalize)
  end

  def location(applicant)
    applicant.location.try(:titleize)
  end

  def tooltip_state(app, state)
    "current-state" if ApplicantStateMachine.determine_state(app) == state
  end

  def can_be_denied?
    @applicant.archived == false
  end

  DISPLAY_STATES = {
    "applied_on" =>
    { "current" => "Applied",
      "waiting" => "Need to send initial contact",
      "court" => "exclamation" },
    "initial_reply_on" =>
    { "current" => "Contacted",
      "waiting" => "Waiting to hear back",
      "court" => "clock-o" },
    "sent_challenge_on" =>
    { "current" => "Requested Submission",
      "waiting" => "Waiting for code submission",
      "court" => "clock-o" },
    "completed_challenge_on" =>
    { "current" => "Submitted Code",
      "waiting" => "Need to review code and provide feedback",
      "court" => "exclamation" },
    "reviewed_on" =>
    { "current" => "Received Feedback",
      "waiting" => "Need to extend offer",
      "court" => "exclamation"},
    "offered_on" =>
    { "current" => "Extended Offer",
      "waiting" => "They Need to Sign the Offer",
      "court" => "clock-o"},
    "decision_made_on" =>
    { "current" => "Completed Application",
      "waiting" => "Completed Application",
      "court" => "folder-open-o" }
  }

  private

  def applied_as_student?
    @applicant.skill == "Student" 
  end

  def interactions_list
    [:initial_reply_on,
     :sent_challenge_on,
     :completed_challenge_on,
     :reviewed_on,
     :resubmitted_challenge_on,
     :decision_made_on]
  end

  def add_interaction(interactions, interaction_type)
    label = interaction_type.to_s.titleize
    interactions[label] = format_date(@applicant.send(interaction_type))
  end

  def normalize_url(url)
    return [] if url.nil?
    url.delete(",").delete(";").split(" ")
  end

  def url_needs_http_prefix?(link)
    /[a-zA-Z]{2,}\.[a-zA-Z]{2,}.*\z/.match(link)
  end
end
