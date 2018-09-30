require 'memory_repository/models/craftsman'
require 'memory_repository/base_repository'
require 'repository'

module MemoryRepository
  class CraftsmanRepository
    include BaseRepository

    def new(attrs = {})
      MemoryRepository::Craftsman.new(attrs)
    end

    def create(attrs = {})
      craftsman = new(attrs)
      if !exisiting_employment_id?(craftsman.employment_id) && craftsman.valid?
        save(craftsman)
      else
        craftsman.add_error(:employment_id, 'has already been taken')
        raise Footprints::RecordNotValid.new(craftsman)
      end
      craftsman
    end

    def find_by_name(name)
      records.values.find { |r| r.name == name }
    end

    def find_by_id(id)
      records.values.find { |r| r.id == id }
    end

    def where(string_query, term)
      matches = records.values.select { |r| r.name.start_with?(term) }
      matches
    end

    def find_by_employment_id(employment_id)
      records.values.find { |r| r.employment_id == employment_id }
    end

    private
    def exisiting_employment_id?(employment_id)
      !find_by_employment_id(employment_id).nil?
    end
  end
end
