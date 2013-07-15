module EveData
  class Group < EveData::EveDataDump
    self.table_name = 'invGroups'
    self.primary_key = :groupID

    belongs_to :category,             :class_name => 'Category', :foreign_key => :categoryID, :primary_key => :categoryID
    belongs_to :icon,                 :class_name => 'Icon', :foreign_key => :iconID, :primary_key => :iconID

    has_many   :types,                 :foreign_key => :groupID
  end
end
