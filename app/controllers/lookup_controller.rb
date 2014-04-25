class LookupController < ApplicationController
  include Ipv4
  include Ripe

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

      return
    end

    if request.post? && params[:dst]
      # limit the requests per minute by IP address
      count = Rails.cache.increment(request.remote_ip, 1, :expires_in => 600)
      puts count
      if count > REQS_LIMIT
        @alert_msg = "You submit too frequently. Please try later."
        return
      end
          
      @tr = Traceroute.create_new(params[:probe], params[:dst])
      redirect_to "/traceroute/#{@tr.uuid}/"
      return
    end

    if params[:uuid]
      @tr = Traceroute.find_by(uuid: params[:uuid])
      return
    end

    probes = Rails.cache.fetch(:probes, :expires_in => 1800) do
      api = API.new
      api.fetch_probes()
    end

    # options for select form
    @probes_options = Hash.new
    probes.each do |p|
      @probes_options[p['name']] = p['id']
    end
  end
end
