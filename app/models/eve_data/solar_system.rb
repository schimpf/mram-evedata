module EveData
  class SolarSystem < EveData::EveDataDump
    self.table_name = 'mapSolarSystems'
    self.primary_key = :solarSystemID

    belongs_to :region,               class_name: 'Region', foreign_key: :regionID, primary_key: :regionID, inverse_of: :solar_systems
    belongs_to :constellation,        class_name: 'Constellation', foreign_key: :constellationID, primary_key: :constellationID, inverse_of: :solar_systems
    belongs_to :faction,              class_name: 'Faction', foreign_key: :factionID, primary_key: :factionID, inverse_of: :solar_systems
    belongs_to :sun_type,             class_name: 'Type', foreign_key: :sunTypeID, primary_key: :sunTypeID, inverse_of: :solar_systems
  end
end
