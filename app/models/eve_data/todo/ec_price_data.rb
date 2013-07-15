require 'open-uri'

class EcPriceData < ActiveRecord::Base

  FRESH_TIMER = 2.hours
  STALE_TIMER = 1.day
  after_initialize :init

  belongs_to :edd_type,             :class_name => 'EddType', :foreign_key => :typeID, :primary_key => :typeID
  belongs_to :solarsystem,          :class_name => 'EddSolarSystem', :foreign_key => :solarSystemID, :primary_key => :solarSystemID

  scope :freshest, joins('INNER JOIN (SELECT typeID,solarSystemID,MAX(ts) AS maxts FROM ec_price_data GROUP BY typeID,solarSystemID HAVING MAX(ts)) AS ec2').where('ec_price_data.typeID = ec2.typeID AND ec_price_data.solarSystemID = ec2.solarSystemID AND ec_price_data.ts = ec2.maxts')
  scope :freshest_nonstale, joins('INNER JOIN (SELECT typeID,solarSystemID,MAX(ts) AS maxts FROM ec_price_data GROUP BY typeID,solarSystemID HAVING MAX(ts)) AS ec2').where(['ec_price_data.typeID = ec2.typeID AND ec_price_data.solarSystemID = ec2.solarSystemID AND ec_price_data.ts = ec2.maxts AND ts >= ?', Time.now - STALE_TIMER])

  def init
    self.ts ||= Time.now
  end

  def fresh?; self.ts >= Time.now - FRESH_TIMER; end
  def stale?; self.ts < Time.now - STALE_TIMER; end

  class << self
    def get_and_parse_ec_xml(utypes, opts)
      alltypes = utypes.dup
      while alltypes.length > 0
        types = alltypes.slice!(0,20)
        ec_url = sprintf("http://api.eve-central.com/api/marketstat?usesystem=%d&typeid=%s", opts[:system_id], types.collect{|x| x.id}.join('&typeid='))
        doc = Nokogiri::XML(open(ec_url))
        doc.xpath('//evec_api/marketstat/type').each do |t|
          pd = EcPriceData.new(:typeID => t[:id], :solarSystemID => opts[:system_id])
          ['all', 'buy', 'sell'].each do |x|
            ['volume', 'avg', 'max', 'min', 'stddev', 'median', 'percentile'].each do |y|
              pd.send("#{x}_#{y}=", t.xpath(".//#{x}/#{y}").inner_text)
            end
          end
          pd.save!
        end
      end
    end

    def update_single(t, uopts = {})
      return unless t
      defopts = { :force => false, :system_id => 30000142, :silent => false }
      opts = defopts.merge uopts
      return unless opts[:force] or t.ec_prices.freshest_nonstale.length == 0

      get_and_parse_ec_xml [t], opts
    end
    
    def update_multiple(arr, uopts = {})
      return unless arr and arr.length > 0
      defopts = { :force => false, :system_id => 30000142, :silent => false }
      opts = defopts.merge uopts

      types = arr.dup
      types.delete_if{|x| !x.published or !x.market_group}
      types.delete_if do |x|
        unless opts[:silent] then
          printf("  check %50s: ", x.typeName)
          ts = x.ec_prices.freshest.first ? x.ec_prices.freshest.first.ts : '<no data>'
          if opts[:force] then
            printf("force in effect, FETCHING\n")
          elsif x.ec_prices.freshest_nonstale.length > 0 then
            printf("non-stale from %s, skipping\n", ts)
          else
            printf("stale from %s, FETCHING\n", ts)
          end
        end
        !opts[:force] and x.ec_prices.freshest_nonstale.length > 0
      end

      return unless types.length > 0
      get_and_parse_ec_xml types, opts
    end

    def update_standard_market_groups(uopts = {})
      defopts = { :silent => false }
      opts = defopts.merge uopts

      mgs = ['Advanced Materials', 'Minerals', 'Industrial Goods', 'Refined Commodities', 'Advanced Commodities', 'Datacores', 'Salvaged Materials', 'Capital Ship Components', 'Control Towers']
      cats = ['Decryptors', 'Sovereignty Structures', 'Ship']

      mgs.each do |mg|
        x = EddMarketGroup.find_by_marketGroupName(mg)
        printf("check mg: %s [%d]\n", mg, x.edd_types.length) unless opts[:silent]
        x.ec_update(opts)
      end
      cats.each do |cat|
        x = EddCategory.find_by_categoryName(cat)
        printf("check cat: %s [%d]\n", cat, x.edd_types.length) unless opts[:silent]
        x.ec_update(opts)
      end
      nil
    end
  end
end
