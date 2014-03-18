class LookupController < ApplicationController
  include Ipv4
  def ip
    if params[:ip]
      begin
        @ip = params[:ip]
        @city = GEO.city(params[:ip])
        @asn = ASN.asn(params[:ip])
      rescue Exception => exc
        @msg = "#{exc.message}"
      end
    end
  end

  def index
    if request.post? && params[:paste]
      @paste = params[:paste]
      @gtr_list = plain_to_list(@paste)
      if @gtr_list.empty?
        return @paste_msg = "bad traceroute format"
      end

      @hash = Gmaps4rails.build_markers(@gtr_list) do |gtr, marker|
        marker.lat(gtr[:lat])
        marker.lng(gtr[:lng])
        marker.picture({
          "url" => "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=#{gtr[:id]}|FE6256|000000",
          "width" => 21,
          "height" => 34,
        })
      end
    end
  end
end
