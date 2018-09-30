require 'ar_repository/models/user'

Footprints::Application.routes.draw do

  get 'auth/google_oauth2/callback', to: 'sessions#create', :as => :new_session
  delete 'sessions/destroy', :as => :sessions_destroy
  get 'sessions/oauth_signin' => 'sessions#oauth_signin', :as => :oauth_signin
  get "applicants" => 'applicants#index'
  get "applicants/unassigned" => 'applicants#unassigned', as: 'unassigned_applicants'
  get "applicants/new" => 'applicants#new', as: 'new_applicant'
  post "applicants/new" => 'applicants#create'
  post "applicants/submit" => 'applicants#submit'
  get "applicants/:id/deny_application" => "applicants#deny_application", as: "deny_application"
  get "applicants/:id/assign_craftsman" => "applicants#assign_craftsman", as: "assign_craftsman"
  post "applicants/assign_craftsman" => "applicants#assign_craftsman", as: "specify_craftsman"
  post "applicants/assign_craftsman_from_applicant" => "applicants#assign_craftsman_from_applicant", as: "assign_craftsman_new"
  get "applicants/:id/hire" => 'applicants#hire', as: "hire_applicant"
  post "update_state/:id" => 'applicants#update_state', :as => 'update_state'
  post "make_decision/:id" => 'applicants#make_decision', :as => 'make_decision'
  get "applicants/:id", to: 'applicants#show', as: 'applicant'
  post "applicants/:id" => 'applicants#update'
  get "applicants/:id/edit",to: 'applicants#edit', as: 'edit_applicant'
  delete "applicants/:id" => 'applicants#destroy'
  get "applicants/:id/offer_letter" => 'applicants#offer_letter'
  get "applicants/:id/offer_letter_form" => 'applicants#offer_letter_form'
  get "applicants/:id/onboarding_letters" => 'applicants#onboarding_letters'
  post "applicants/:id/update_employment_dates" => 'applicants#update_employment_dates'
  patch "applicants/:id/unarchive" => 'applicants#unarchive', as: "unarchive_applicant"

  get 'users/:id', to: 'users#show', as: 'user'
  get 'users/:id/edit', to: 'users#edit', as: 'edit_user'
  post 'users/:id', to: 'users#update'

  post "messages/create" => 'messages#create'

  post "notes/create" => "notes#create", as: 'notes'
  get "notes/:id/edit" => "notes#edit", as: 'note'
  patch "notes/update/:id" => "notes#update", as: 'note_update'

  get "analytics" => "analytics#index"
  get "profile" => "craftsmen#profile", as: 'profile'
  get "craftsmen/seeking" => "craftsmen#seeking", as: 'craftsmen'
  put "craftsman/update" => "craftsmen#update"

  get "search_suggestions" => 'search_suggestions#index'
  get "craftsman_suggestions" => 'search_suggestions#craftsman_suggestions'
  get "dashboard/confirm_applicant_assignment" => "dashboard#confirm_applicant_assignment", as: 'confirm_applicant_assignment'
  get "dashboard/decline_applicant_assignment" => "dashboard#decline_applicant_assignment", as: 'decline_applicant_assignment'
  post "dashboard/decline_all_applicants" => "dashboard#decline_all_applicants", as: 'decline_all_applicants'

  get "templates" => "dashboard#email_templates", as: "templates"

  get "admin" => "admin#index", as: "admin"

  get "salaries/edit" => "salaries#edit", as: "salaries"
  post "salaries/create_monthly" => "salaries#create_monthly"
  post "salaries/create_annual" => "salaries#create_annual"
  post "salaries/update" => "salaries#update"
  delete "salaries/:id" => "salaries#destroy", as: "destroy_salary"

  get "reporting" => "reporting#index", as: "reporting"

  get "apprentices" => "apprentices#index", as: "apprentices"
  get "apprentices/new" => 'apprentices#new', as: 'new_apprentice'
  post "apprentices/new" => 'apprentices#create'
  # post "apprentices/submit" => 'apprentices#submit'
  # get "apprentices/:id/deny_apprentice" => "apprentices#deny_apprentice", as: "deny_apprentice"
  get "apprentices/:id" => "apprentices#edit"
  put "apprentices/:id" => "apprentices#update"


  root :to => "dashboard#index"
end
