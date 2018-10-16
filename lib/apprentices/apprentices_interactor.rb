require 'warehouse/identifiers'
require 'warehouse/json_api'
require 'warehouse/token_http_client'
require 'warehouse/api_factory'
require 'warehouse/fake_api'
require 'warehouse/api_wrapper'

class ApprenticesInteractor
  NoResident = Class.new

  class AuthenticationError < RuntimeError
  end

  attr_reader :auth_token

  def initialize(auth_token, instance_warehouse = nil)
    @auth_token = auth_token
    @warehouse = instance_warehouse unless instance_warehouse.nil?
  end

  def fetch_all_residents
    warehouse.find_all_employments.select do |employment|
      valid_resident? employment
    end
  rescue Warehouse::AuthenticationError, Warehouse::AuthorizationError => e
    raise AuthenticationError.new(e.message)
  end

  def fetch_all_students
    warehouse.find_all_apprenticeships.select do |apprenticeship|
      current?(apprenticeship) && student?(apprenticeship)
    end
  rescue Warehouse::AuthenticationError, Warehouse::AuthorizationError => e
    raise AuthenticationError.new(e.message)
  end

  def modify_resident_end_date!(raw_resident, date)
    raw_resident[:end] = date
    warehouse.update_employment!(raw_resident[:id], raw_resident)
  end

  def modify_corresponding_craftsman_start_date!(raw_resident, date)
    raw_craftsman = fetch_corresponding_craftsman_employment(raw_resident)
    if raw_craftsman
      raw_craftsman[:start] = date
      warehouse.update_employment!(raw_craftsman[:id], raw_craftsman)
    end
  end

  def fetch_resident_by_id(employment_id)
    employment = warehouse.find_employment_by_id(employment_id)
    valid_resident?(employment) ? employment : NoResident
  end

  def fetch_corresponding_craftsman_employment(resident)
    craftsman = warehouse.find_all_employments.select do |employment|
      corresponding_craftsman?(resident, employment)
    end
    craftsman.first
  end

  private

  def warehouse
    client = Warehouse::TokenHttpClient.new(host: WAREHOUSE_URL, id_token: auth_token)
    @warehouse ||= Warehouse::APIFactory.create(client)
  end

  def valid_resident?(employment)
    resident?(employment) && current?(employment)
  end

  def resident?(employment)
    Warehouse::APPRENTICE_POSITION_NAMES.values.include?(employment[:position][:name])
  end

  def craftsman?(employment)
    Warehouse::CRAFTSMAN_POSITION_NAMES.values.include?(employment[:position][:name])
  end

  def student?(apprenticeship)
    apprenticeship[:skill_level] == "student"
  end

  def current?(employment)
    startdate = employment[:start] <= Date.current
    enddate = (employment[:end].nil? || employment[:end] > Date.current)
    startdate && enddate
  end

  def corresponding_craftsman?(resident, employment)
    true if (resident[:person][:id] == employment[:person][:id]) && craftsman?(employment)
  end
end
