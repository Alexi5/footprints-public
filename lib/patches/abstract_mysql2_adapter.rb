# Ensure the mysql2 gem uses the correct column definition for MySQL 5.7+
#
# @see https://stackoverflow.com/questions/21075515/creating-tables-and-problems-with-primary-key-in-rails
# @see https://stackoverflow.com/questions/37315546/uninitialized-constant-activerecordconnectionadaptersmysql2adapternative-d
require 'active_record/connection_adapters/mysql2_adapter'
NativeDbTypesOverride.configure({
  ActiveRecord::ConnectionAdapters::Mysql2Adapter => {
    primary_key: "int(11) auto_increment PRIMARY KEY"
  }
})