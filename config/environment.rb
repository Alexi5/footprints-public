require './config/application'
# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Footprints::Application.initialize!

# Patch mysql2 for MySQL 5.7+ compatibility
require File.expand_path('../../lib/patches/abstract_mysql2_adapter', __FILE__)