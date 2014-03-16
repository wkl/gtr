class LookupController < ApplicationController
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
  end
end
