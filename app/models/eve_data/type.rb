module EveData
  class Type < EveData::EveDataDump
    self.table_name = 'invTypes'

    belongs_to :group,                :class_name => 'Group', :foreign_key => :groupID, :primary_key => :groupID
    belongs_to :graphic,              :class_name => 'Graphic', :foreign_key => :graphicID, :primary_key => :graphicID
    belongs_to :race,                 :class_name => 'Race', :foreign_key => :raceID, :primary_key => :raceID
    belongs_to :category,             :class_name => 'Category', :foreign_key => :categoryID, :primary_key => :categoryID
    belongs_to :market_group,         :class_name => 'MarketGroup', :foreign_key => :marketGroupID, :primary_key => :marketGroupID
    belongs_to :icon,                 :class_name => 'Icon', :foreign_key => :iconID, :primary_key => :iconID

    has_one :made_from_blueprint,     :class_name => 'BlueprintType', :foreign_key => :productTypeID
    has_one :meta_type,               :class_name => 'MetaType', :foreign_key => :typeID

    has_many :meta_parent_for,        :class_name => 'MetaType', :foreign_key => :parentTypeID
    has_many :materials,              :class_name => 'TypeMaterial', :foreign_key => :typeID
    has_many :type_requirements,      :class_name => 'TypeRequirement', :foreign_key => :typeID
    has_many :ec_prices,              :class_name => 'EcPriceData', :foreign_key => :typeID

    has_many :eve_type_attrs,         :class_name => 'TypeAttribute', :foreign_key => :typeID
    has_many :eve_attrs,              :class_name => 'AttributeType', :through => :eve_type_attrs

    has_many :reaction_components,    :class_name => 'TypeReaction', :foreign_key => :reactionTypeID

    def ec_update(opts = {})
      EcPriceData.update_single(self, opts)
    end

    def ec_price(uopts = {})
      defopts = { :system_id => 30000142, :mode => :sell, :type => :min }
      opts = defopts.merge uopts

      ecp = self.ec_prices.freshest_nonstale
      return false unless ecp and ecp.length > 0
      BigDecimal.new(ecp.first.send("#{opts[:mode]}_#{opts[:type]}").to_s).round(2)
    end

    def build_price(uopts = {})
      return false unless self.made_from_blueprint
      mybp = self.made_from_blueprint

      puts "debug: techlevel = #{mybp.techLevel}"
      case mybp.techLevel
      when 1
        mybp.all_materials(:resolve => true).total_price / self.portionSize
      when 2
        t1_parent = self.meta_type.parent_type
        t1_cost = t1_parent.made_from_blueprint.all_materials.(:resolve => true).total_price / t1_parent.portionSize
  #puts mybp.all_materials(:resolve => true)
  puts mybp.all_materials(:resolve => true, :me => -4)
  #      t2_cost = mybp.all_materials.total_price / self.portionSize

      end
    end

    def reaction
      comps = self.reaction_components
      return nil unless comps.length > 0

      bill_in = MaterialBill.new(self)
      bill_out = MaterialBill.new(self)
      comps.each do |x|
        moon_mining_attr = x.component_type.eve_type_attrs.find_by_attributeID(726)
        moon_mining_amount = moon_mining_attr ? (moon_mining_attr.valueInt ? moon_mining_attr.valueInt : moon_mining_attr.valueFloat) : 1
        real_quant = x.quantity * moon_mining_amount
        if x.input then
          bill_in << MaterialBillEntry.new(:type => x.component_type, :quantity => real_quant)
        else
          bill_out << MaterialBillEntry.new(:type => x.component_type, :quantity => real_quant)
        end
      end
      puts bill_in
      puts bill_out
    end
  end
end
