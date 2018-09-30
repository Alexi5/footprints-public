require 'warehouse/fake_api'
require 'warehouse/json_api'

module Warehouse
  class APIFactory
    class << self
      attr_accessor :class_name

      def create(client)
        class_name.new(client)
      end
    end
  end
end