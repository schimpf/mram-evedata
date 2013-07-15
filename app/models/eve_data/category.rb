module EveData
  class Category < EveData::EveDataDump
    self.table_name = 'invCategories'
    self.primary_key = :categoryID

    has_many          :groups,                :foreign_key => :categoryID
    has_many          :types,                 :through => :groups

    def ec_update(opts = {})
      EcPriceData.update_multiple(self.types, opts)
    end
  end
end
