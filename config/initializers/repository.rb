require 'repository'
require 'memory_repository/memory_repository'
require 'ar_repository/ar_repository'

Footprints::Repository.register_repo(ArRepository)
