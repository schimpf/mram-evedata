class EddAttributeType < EveDataDump
  self.table_name = 'dgmAttributeTypes'
  self.primary_keys = :typeID, :attributeID

  has_many :eve_type_attrs,         :class_name => 'EddAttributeType', :foreign_key => :attributeID, :primary_key => :attributeID
  has_many :types,                  :class_name => 'EddType', :foreign_key => :typeID, :primary_key => :typeID
end
