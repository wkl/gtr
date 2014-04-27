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

  def check
    #if !request.post?
    #  render :json => {
    #    :code => '-1',
    #    :msg => 'method not allowed',
    #  }
    #end
    @tr = Traceroute.find_by(uuid: params[:uuid])
    if @tr.nil?
      render :json => {
        :code => '-1',
        :msg => 'traceroute not found',
      }
      return
    end

    if @tr.failed?
      render :json => {
        :code => '-1',
        :msg => 'traceroute failed, please check your destination',
      }
      return
    end

    if @tr.available?
      render :json => {
        :code => '1',
        :msg => '',
      }
    else
      render :json => {
        :code => '0',
        :msg => '',
      }
    end
    return

  end

  def index
    @gtr_list = []
    @gtr_list_skip = []

    if request.post? && params[:paste]
      @paste = params[:paste]
      @gtr_list = plain_to_list(@paste)
      if @gtr_list.empty?
        return @paste_msg = "bad traceroute format"
      end
      @gtr_lis_skip = skipfy(@gtr_list)

=begin
      @hash = Gmaps4rails.build_markers(@gtr_list) do |gtr, marker|
        marker.lat(gtr[:lat])
        marker.lng(gtr[:lng])
        marker.picture({
          "url" => "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=#{gtr[:id]}|FE6256|000000",
          "width" => 21,
          "height" => 34,
        })
      end
=end
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

      unless @tr.nil?
        @gtr_list = @tr.to_list
        if (@gtr_list.length > 0)
          @gtr_list_skip = skipfy(@gtr_list)
        end
      end
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
