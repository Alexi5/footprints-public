require 'warehouse/api_factory'
require 'warehouse/fake_api'
require 'warehouse/json_api'

if Rails.env.local?
  WAREHOUSE_URL = "http://0.0.0.0:8080"
  Warehouse::APIFactory.class_name = Warehouse::FakeAPI
else
  WAREHOUSE_URL = "https://warehouse-staging.abcinc.com"
  Warehouse::APIFactory.class_name = Warehouse::FakeAPI
end
