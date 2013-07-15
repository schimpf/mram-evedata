class EddRace < EveDataDump
  self.table_name = 'chrRaces'
  self.primary_key = :raceID

  belongs_to :icon,                 :class_name => 'EddIcon', :foreign_key => :iconID, :primary_key => :iconID
end
