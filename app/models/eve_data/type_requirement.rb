module EveData
  class TypeRequirement < EveData::EveDataDump
    self.table_name = 'ramTypeRequirements'
    self.primary_key = :typeID, :activityID, :requiredTypeID

    belongs_to :type,                 class_name: 'Type', foreign_key: :typeID, inverse_of: :type_requirements
    belongs_to :required_type,        class_name: 'Type', foreign_key: :requiredTypeID, primary_key: :typeID
    belongs_to :activity,             class_name: 'Activity', foreign_key: :activityID, primary_key: :ActivityID

    belongs_to :bptype,               class_name: 'BlueprintType', foreign_key: :typeID, primary_key: :blueprintTypeID

    scope :for_manuf, where(:activityID => Activity[:Manufacturing].id)
    scope :for_inv, where(:activityID => Activity[:Invention].id)
  end
end
