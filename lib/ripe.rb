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
          break if count >= 7 # find 7 probes for each country
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

      return probes
    end

    # submit traceroute measurement, should return msm_id
    # otherwise raise Exception
    def submit(probe, dest)
      body = {
        'definitions' => [
          {
            'target' => dest,
            'description' => 'GTR',
            'type' => 'traceroute',
            'af' => 4,
            'is_oneoff' => true,
            'is_public' => false,
            'protocol' => 'ICMP',
            'resolve_on_probe' => true,
            'packets' => 1,
          },
        ],
        'probes' => [
          {
            'requested' => 1,
            'type' => 'probes',
            'value' => "#{probe}",
          }
        ],
      }

      @options = {
        :body => JSON.generate(body),
        :query => {
          :key => RIPE_CREATE_KEY,
        },
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
        }
      }
      resp = self.class.post('/measurement/', @options)
      puts resp.code unless resp.code == 202
      raise resp.body unless resp.code == 202

      return JSON.parse(resp.body)['measurements'].first
    end

    def fetch_result(msm_id)
      @options = {
        :query => {
          :key => RIPE_FETCH_KEY,
        },
      }
      resp = self.class.get("/measurement/#{msm_id}/result/", @options)
      raise resp.body if resp.code != 200

      return JSON.parse(resp.body)
    end
  end
end

include Ripe

if __FILE__ == $0
  api = API.new
  api.submit(207, 'g.cn')
end
