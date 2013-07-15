class MaterialBillEntry
  attr_accessor :type, :quantity, :damage_per_job, :recycle, :price

  def initialize(opts = {})
    unless opts[:type].instance_of?(EddType) and opts.has_key?(:quantity) then
      raise ArgumentError.new("wrong arguments :(")
    end
    merged = { :damage_per_job => 1, :recycle => false }.merge(opts)
    self.type = merged[:type]
    self.quantity = merged[:quantity]
    self.damage_per_job = merged[:damage_per_job]
    self.recycle = merged[:recycle]
    self.price = merged[:price] || self.type.ec_price
  end
end
