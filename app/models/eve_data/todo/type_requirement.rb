class EddTypeRequirement < EveDataDump
  self.table_name = 'ramTypeRequirements'
  self.primary_key = :typeID, :activityID, :requiredTypeID

  belongs_to :type,                 :class_name => 'EddType', :foreign_key => :typeID, :primary_key => :typeID
  belongs_to :required_type,        :class_name => 'EddType', :foreign_key => :requiredTypeID, :primary_key => :typeID
  belongs_to :activity,             :class_name => 'EddActivity', :foreign_key => :activityID, :primary_key => :ActivityID

  belongs_to :bptype,               :class_name => 'EddBlueprintType', :foreign_key => :typeID, :primary_key => :blueprintTypeID

  scope :for_manuf, where(:activityID => EddActivity[:Manufacturing].id)
  scope :for_inv, where(:activityID => EddActivity[:Invention].id)
end
