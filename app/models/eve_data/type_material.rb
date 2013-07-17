module EveData
  class TypeMaterial < EveData::EveDataDump
    self.table_name = 'invTypeMaterials'
#    self.primary_keys = :typeID, :materialTypeID

    belongs_to :material,        class_name: 'Type', foreign_key: :materialTypeID
  end
end
