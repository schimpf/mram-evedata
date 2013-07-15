class EddGraphic < EveDataDump
  self.table_name = 'eveGraphics'
  self.primary_key = :graphicID

  belongs_to :explosion,            :class_name => 'EddGraphic', :foreign_key => :explosionID, :primary_key => :graphicID
end
