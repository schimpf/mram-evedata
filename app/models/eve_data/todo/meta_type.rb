class EddMetaType < EveDataDump
  self.table_name = 'invMetaTypes'
  self.primary_key = :typeID

  belongs_to :edd_type,             :foreign_key => :typeID
  belongs_to :parent_type,          :class_name => 'EddType', :foreign_key => :parentTypeID
  belongs_to :meta_group,           :class_name => 'EddMetaGroup', :foreign_key => :metaGroupID
end
