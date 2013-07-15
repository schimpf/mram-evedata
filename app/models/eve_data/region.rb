module EveData
  class Region < EveData::EveDataDump
    self.table_name = 'mapRegions'
    self.primary_key = :regionID

    belongs_to :faction,              class_name: 'Faction', foreign_key: :factionID, inverse_of: :regions

    has_many :constellations, foreign_key: :regionID, inverse_of: :region
    has_many :solar_systems, foreign_key: :regionID, inverse_of: :region
  end
end
