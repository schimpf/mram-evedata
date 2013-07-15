module EveData
  class EveData::EveDataDump < ActiveRecord::Base
    self.abstract_class = true
    establish_connection :eve_data
  end
end
