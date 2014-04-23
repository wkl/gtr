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

  def plain_to_list(plain)
    gtr_list = Array.new
    plain.split("\n").each do |line|
      id, ip = line.split[0..1]
      next unless is_number?(id) && valid_v4?(ip)
      begin
        geo = GEO.city(ip)
        asn = ASN.asn(ip)
      rescue
        return []
      end
      gtr_list << {
        :id => id,
        :ip => ip,
        :asn => asn.nil? ? 'n/a' : asn.number,
        :as => asn.nil? ? 'n/a' : asn.asn,
        :cc => geo.country_code2,
        :lat => geo.latitude,
        :lng => geo.longitude,
      }
    end
    gtr_list
  end
end

include Ipv4

if __FILE__ == $0
end
