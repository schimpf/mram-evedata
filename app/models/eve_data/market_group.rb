require 'ancestry'

module EveData
  class MarketGroup < EveData::EveDataDump
    self.table_name = 'invMarketGroups'
    self.primary_key = :marketGroupID

    has_ancestry      :cache_depth => true
    has_many          :types,                 :foreign_key => :marketGroupID

    def ec_update(opts = {})
      EcPriceData.update_multiple(self.edd_types, opts)
    end
  end
end
