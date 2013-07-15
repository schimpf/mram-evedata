class EddTypeMaterial < EveDataDump
  self.table_name = 'invTypeMaterials'
  self.primary_keys = :typeID, :materialTypeID

  belongs_to :type,                 :class_name => 'EddType', :foreign_key => :typeID, :primary_key => :typeID
  belongs_to :material_type,        :class_name => 'EddType', :foreign_key => :materialTypeID, :primary_key => :typeID
end
