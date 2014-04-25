module Ripe
  require 'HTTParty'
  require 'json'
  #CC_LIST = ['AU', 'BR', 'CA', 'CN', 'DK', 'FR', 'DE', 'IN', 'JP', 'GB', 'US']

  class API
    include HTTParty
    base_uri 'https://atlas.ripe.net/api/v1'

    def fetch_cc_active_probes(cc)
      @options = {
        :query => {
          :country_code => cc,
          :limit => 20,
          :fields => 'id,country_code,address_v4,status,latitude,longitude,location'
        }
      }
      self.class.get('/probe/', @options)
    end

    # "try to" get probes of pre-defined country list
    # https://atlas.ripe.net/docs/rest/#probe
    def fetch_probes
      probes = Array.new

      for cc in CC_LIST
        begin
          resp = fetch_cc_active_probes(cc)
          raise "Non-200 response" if resp.code != 200
        rescue Exception => exc
          puts "failed to fetch #{cc}: #{exc.message}, skipping"
          next
        end

        count = 0
        ret_list = JSON.parse(resp.body)['objects']
        ret_list.each do |probe|
          break if count >= 5 # only find 3 probes for each country
          next if probe['status'] != 1 # get connected probe

          if probe.has_key?('location')
            probe['name'] = "#{cc}: #{probe['location']}"
          else
            probe['name'] = "#{cc}: (unknown location)"
          end
          probes << probe
          count += 1
        end
      end

      probes
    end

  end
end

include Ripe

if __FILE__ == $0
  api = API.new
  api.fetch_probes
end
