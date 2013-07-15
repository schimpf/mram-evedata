class EddActivity < EveDataDump
  self.table_name = 'ramActivities'
  self.primary_key = :activityID

  has_many :materials,              :class_name => 'EddTypeRequirements', :foreign_key => :activityID

  class << self
    def [](act)
      self.find_by_activityName(act)
    end
  end
end
