module EveData
  class Constellation < EveData::EveDataDump
    self.table_name = 'mapConstellations'
    self.primary_key = :constellationID

    belongs_to :region,               class_name: 'Region', foreign_key: :regionID, primary_key: :regionID, inverse_of: :constellations

    has_many :solar_systems, foreign_key: :constellationID, inverse_of: :constellation
  end
end
