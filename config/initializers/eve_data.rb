class EveData::DbConfigMissingException < ActiveRecord::ActiveRecordError
end

class EveData::DataDumpMissing < ActiveRecord::ActiveRecordError
end

unless ActiveRecord::Base.configurations.has_key?("eve_data")
  puts "**********************************************************"
  puts "ActiveRecord database configuration missing for 'eve_data'"
  puts ""
  puts "you need to add a block in your config/database.yml"
  puts "**********************************************************"
  raise EveData::DbConfigMissingException
end

