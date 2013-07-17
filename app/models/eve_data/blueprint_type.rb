module EveData
  class BlueprintType < EveData::EveDataDump
    self.table_name = 'invBlueprintTypes'
    self.primary_key = :blueprintTypeID

    belongs_to :blueprint,            class_name: 'Type', foreign_key: :blueprintTypeID, inverse_of: :rel_bp_produces
    belongs_to :product,              class_name: 'Type', foreign_key: :productTypeID, inverse_of: :rel_bp_product
#    belongs_to :parent_blueprint,     class_name: 'Type', foreign_key: :parentBlueprintTypeID, primary_key: :typeID

    has_many :type_requirements,      class_name: 'TypeRequirement', foreign_key: :typeID
  #  has_many :req_types,              through: :type_requirements, source: :required_type

    def raw_materials(uopts = {})
      defopts = { resolve: false }
      opts = defopts.merge uopts
      bill = MaterialBill.new(self)

      self.product.materials.each do |x|
        bill << MaterialBillEntry.new(type: x.material, quantity: x.quantity)
      end

      if opts[:resolve] then
        newbill = MaterialBill.new(self)
        bill.entries.each_index do |idx|
  #        if bill.entries[idx].type.made_from_blueprint then
          if bill.entries[idx].type.made_from_blueprint and bill.entries[idx].type.id != 11483 then
            itembill = bill.entries[idx].type.made_from_blueprint.all_materials(opts.merge({me: nil}))
            itembill.multiply!(bill.entries[idx].quantity)
            newbill.add!(itembill)
          else
            newbill << bill.entries[idx]
          end
        end
  puts "RAW_before #{bill}"
  puts "RAW_after #{newbill}"
        bill = newbill.stack
      end

      bill
    end

    def extra_materials(uopts = {})
      defopts = { resolve: false }
      opts = defopts.merge uopts
      bill = MaterialBill.new(self)

      bill.entries = self.type_requirements.for_manuf.joins(required_type: :group).where('invGroups.categoryID != 16').collect do |x|
  #      { type: x.required_type, quantity: x.quantity, damage_per_job: x.damagePerJob, recycle: x.recycle }
        MaterialBillEntry.new(type: x.required_type, quantity: x.quantity, damage_per_job: x.damagePerJob, recycle: x.recycle)
      end

      if opts[:resolve] then
        newbill = MaterialBill.new(self)
        bill.entries.each_index do |idx|
  #        if bill.entries[idx].type.made_from_blueprint then
          if bill.entries[idx].type.made_from_blueprint and bill.entries[idx].type.id != 11483 then
            itembill = bill.entries[idx].type.made_from_blueprint.all_materials(opts.merge({me: nil}))
            itembill.multiply!(bill.entries[idx].quantity * bill.entries[idx].damage_per_job)
            newbill.add!(itembill)
          else
            newbill << bill.entries[idx]
          end
        end
  puts "XTR_before #{bill}"
  puts "XTR_after #{newbill}"
        bill = newbill.stack
      end

      bill
    end
    
    def all_materials(uopts = {})
      defopts = { resolve: false, me: nil, stack: true }
      opts = defopts.merge uopts

      bill = nil
      raw_bill = self.raw_materials(opts)

      case self.techLevel
      when 0,1
        bill = raw_bill
      when 2
        if self.product.meta_type then
          t1_raw_bill = self.product.meta_type.parent_type.made_from_blueprint.raw_materials
          bill = raw_bill.subtract(t1_raw_bill)
        else
          bill = raw_bill
        end
      end
        
      if opts[:me] != nil then
        if opts[:me] >= 0 then
          bill.multiply!(1 + self.wasteFactor/100.0 * (1.0 / (opts[:me] + 1.0)) )
        else
          bill.multiply!(1 + self.wasteFactor/100.0 * (1.0 - opts[:me]) )
        end
      end
      totalbill = bill.add(self.extra_materials(opts))
      opts[:stack] ? totalbill.stack : totalbill
    end

    def req_skills
      self.type_requirements.joins(required_type: :group).where(invGroups: {categoryID: 16})
    end
  end
end
