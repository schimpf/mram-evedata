class EddTypeAttribute < EveDataDump
  self.table_name = 'dgmTypeAttributes'
  self.primary_keys = :typeID, :attributeID

  belongs_to :type,                 :class_name => 'EddType', :foreign_key => :typeID, :primary_key => :typeID
  belongs_to :eve_attr,             :class_name => 'EddAttributeType', :foreign_key => :attributeID, :primary_key => :attributeID
end
