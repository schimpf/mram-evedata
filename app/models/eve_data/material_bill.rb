require 'csv'

module EveData
  class MaterialBill
    include ActionView::Helpers::NumberHelper

    attr_accessor :entries

    def initialize(bill_for, entries = [])
      @bill_for = bill_for
      @entries = entries
    end

    def <<(entry)
      raise ArgumentError.new("need MaterialBillEntry") unless entry.instance_of?(MaterialBillEntry)

      @entries << entry
    end

    def add(bill)
      raise ArgumentError.new("need MaterialBill") unless bill.instance_of?(MaterialBill)

      newbill = self.dup
      newbill.entries = self.entries + bill.entries
      newbill
    end

    def add!(bill)
      raise ArgumentError.new("need MaterialBill") unless bill.instance_of?(MaterialBill)

      @entries += bill.entries
      self
    end

    def subtract(bill2)
      raise ArgumentError.new("need MaterialBill") unless bill2.instance_of?(MaterialBill)

      newbill = self.stack
      bill2.entries.each do |e2|
        newbill.entries.each_index do |e_idx|
          e = newbill.entries[e_idx]
          if e.type == e2.type then
            e.quantity -= e2.quantity
            newbill.entries.delete_at(e_idx) if e.quantity <= 0
          end
        end
      end
            
      newbill
    end

    def stack
      self.dup.stack!
    end

    def stack!
      seen_type_ids = {}
      new_entries = []

      @entries.each_index do |idx|
        e = @entries[idx]
  #puts "DEBUG: #{e.type.typeName} seen_type_ids[e.type.id] -> #{seen_type_ids[e.type.id]}"
  #if seen_type_ids.has_key?(e.type.id)
  #  puts "DEBUG: new_entries[seen_type_ids[e.type.id]] -> #{new_entries[seen_type_ids[e.type.id]]}"
  #  new_entries.each_index do |idx|
  #    x = new_entries[idx]
  #    puts "idx #{idx} type #{x.type.typeName} quant #{x.quantity}"
  #  end
  #end
        if seen_type_ids.has_key?(e.type.id) and new_entries[seen_type_ids[e.type.id]].damage_per_job == e.damage_per_job then
          new_entries[seen_type_ids[e.type.id]].quantity += e.quantity
        else
          new_entries << e
          seen_type_ids[e.type.id] = new_entries.length - 1
        end
      end

      @entries = new_entries
      self
    end

    def multiply(x)
      self.dup.multiply!
    end

    def multiply!(x)
      @entries.each {|e| e.quantity = (e.quantity.to_f * x.to_f).round }
      self
    end

    def calc_damage
      self.dup.calc_damage!
    end

    def calc_damage!
      @entries.each {|e| e.quantity *= e.damage_per_job }
      self
    end

    def total_price
      total = BigDecimal.new('0.0')
      @entries.each {|e| total += e.price * e.quantity }
      total
    end

    def to_s
      product = @bill_for.is_a?(BlueprintType) ? @bill_for.product : @bill_for
      printf "Material Bill for %s:\n", product.typeName
      printf "%s\n", '-' * 60
      @entries.each do |e|
        printf "%10d %40s %20s\n", e.quantity, e.type.typeName, (e.price ? number_with_precision(e.price*e.quantity, seperator: ',', delimiter: '.', precision: 2) : 'n/a')
      end
    end

    def to_csv
      product = @bill_for.is_a?(BlueprintType) ? @bill_for.product : @bill_for
      printf "quantity;typeName;price"
      @entries.each do |e|
        printf "%s;%s;%s\n", e.quantity, e.type.typeName, (e.price ? number_with_precision(e.price*e.quantity, seperator: ',', delimiter: '.', precision: 2) : 'n/a')
      end
    end

    def to_t1min_ary
      t1min_list = { 'Tritanium' => 0, 'Pyerite' => 0, 'Mexallon' => 0, 'Isogen' => 0, 'Nocxium' => 0, 'Zydrine' => 0, 'Megacyte' => 0 }
      @entries.each_index do |idx|
        e = @entries[idx]
        t1min_list[e.type.typeName] = e.quantity if t1min_list.has_key?(e.type.typeName)
      end
      [ product.typeName, t1min_list.values ].flatten
    end
  end
end
