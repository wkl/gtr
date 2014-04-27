module Ipv4
  def valid_v4?(addr)
    # http://stackoverflow.com/a/14197623/298449
    if /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\Z/ =~ addr
      return $~.captures.all? {|i| i.to_i < 256}
    end
    return false
  end

  def is_number?(str)
    true if Float(str) rescue false
  end

  def gtr_fill(id, ip, rtt)
    raise "invalid number #{id}" unless is_number?(id)

    unless valid_v4?(ip)
      return {
        :id => id,
        :ip => '*',
        :rtt => '',
        :asn => '',
        :as => '',
        :cc => '',
        :lat => 'n/a',
        :lng => 'n/a',
        :info => 'n/a',
      }
    end

    geo = GEO.city(ip)  # geo will be nil if ip is private
    asn = ASN.asn(ip)

    ret = {
      :id => id,
      :ip => ip,
      :rtt => rtt,
      :asn => asn.nil? ? 'n/a' : asn.number,
      :as => asn.nil? ? 'n/a' : asn.asn,
      :cc => geo.nil? ? 'n/a' : geo.country_code2,
      :lat => geo.nil? ? 'n/a' : geo.latitude,
      :lng => geo.nil? ? 'n/a' : geo.longitude,
      :info => '',
    }
    unless geo.nil?
      ret[:info] = "<div>#{ret[:ip]}<br>City: #{geo.city_name}<br>
      Region: #{geo.region_name}<br>Country: #{geo.country_name}<br>
      #{ret[:asn]}: #{ret[:as]}
      </div>"
    end

    return ret
  end

  def plain_to_list(plain)
    gtr_list = Array.new
    plain.split("\n").each do |line|
      id, ip, rtt = line.split[0..2]
      next unless is_number?(id)
      begin
        gtr_list << gtr_fill(id, ip, rtt)
      rescue Exception => exc
        puts exc.message
        return []
      end
    end

    return gtr_list
  end
end

include Ipv4

if __FILE__ == $0
end
