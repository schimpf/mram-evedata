module EveData
  class Activity < EveData::EveDataDump
    self.table_name = 'ramActivities'
    self.primary_key = :activityID

    has_many :materials,              class_name: 'TypeRequirements', foreign_key: :activityID, inverse_of: :activities

    class << self
      def [](act)
        self.find_by_activityName(act)
      end
    end
  end
end
