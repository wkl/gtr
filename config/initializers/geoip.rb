file = File.join(Rails.root, 'data/GeoLiteCity.dat')
if File.exist?(file)
  GEO = GeoIP.new(file)
else
  puts "Geo City data (#{file}) not found."
  GEO = nil
end

file = File.join(Rails.root, 'data/GeoIPASNum.dat')
if File.exist?(file)
  ASN = GeoIP.new(file)
else
  puts "Geo ASN data (#{file}) not found."
  ASN = nil
end
