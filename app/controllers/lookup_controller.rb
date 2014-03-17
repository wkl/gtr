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
    end
  end
end
