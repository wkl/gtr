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
        :city => '',
        :region => '',
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
      :city => geo.nil? ? 'n/a' : geo.city_name,
      :region => geo.nil? ? 'n/a' : geo.region_name,
      :info => 'n/a',
    }
    unless geo.nil?
      ret[:info] = "<div><strong>#{ret[:ip]}</strong><br>City: #{geo.city_name}<br>
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

  def strip_by_as(gtr_list)
    new_list = Array.new

    last_asn = ''
    gtr_list.each do |hop|
      asn = hop[:asn]
      if asn.start_with?('AS') && asn != last_asn
        new_list << hop.clone
      elsif !asn.start_with?('AS')
        new_list << hop.clone
      end
      last_asn = asn
    end

    return new_list
  end

  def skipfy(gtr_list)
    new_list = Array.new
    gtr_list.each do |hop|
      new_list << hop.clone
    end

    i = 0;
    while (i < new_list.length)
      curr = new_list[i]
      if (curr[:lat] != 'n/a' && curr[:city] == '' && curr[:region] == '')
        j = i - 1;
        # find if there are other "accurate" hops in that country
        while (j >= 0 && (new_list[j][:ip] == '*' || new_list[j][:cc] == curr[:cc]))
          if (new_list[j][:city] != '' || new_list[j][:region] != '')
            if (new_list[j][:lat] != 'n/a')
              curr[:lat] = 'n/a'
              curr[:lng] = 'n/a'
              break
            end
          end
          j -= 1
        end

        next if curr[:lat] == 'n/a'

        j = i + 1;
        while (j < new_list.length && (new_list[j][:ip] == '*' ||  new_list[j][:cc] == curr[:cc]))
          if (new_list[j][:city] != '' || new_list[j][:region] != '')
            if (new_list[j][:lat] != 'n/a')
              curr[:lat] = 'n/a'
              curr[:lng] = 'n/a'
              break
            end
          end
          j += 1
        end
      end
      i += 1
    end

    return new_list
  end
end

include Ipv4

if __FILE__ == $0
end
