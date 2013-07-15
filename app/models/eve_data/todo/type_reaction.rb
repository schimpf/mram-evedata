class EddTypeReaction < EveDataDump
  self.table_name = 'invTypeReactions'
  self.primary_keys = :reactionTypeID, :typeID, :input

  belongs_to :type,                 :class_name => 'EddType', :foreign_key => :reactionTypeID, :primary_key => :typeID
  belongs_to :component_type,       :class_name => 'EddType', :foreign_key => :typeID, :primary_key => :typeID
end
