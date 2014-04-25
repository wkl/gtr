class Traceroute < ActiveRecord::Base
  include Ripe
  has_many :hops, -> { order "no ASC" }, :dependent => :delete_all

  # after user post
  def self.create_new(probe, dst)
      tr = self.new
      tr.probe = probe
      tr.dst = dst
      tr.submitted = false
      tr.available = false
      tr.failed = false
      tr.uuid = SecureRandom.uuid
      tr.save
      tr
  end

  def submit
    api = API.new
    begin
      self.msm_id = api.submit(self.probe, self.dst)
      self.submitted = true
      puts self.msm_id
    rescue Exception => exc
      self.failed = true
      puts exc.message
    end
    self.save
  end

  def fetch
    api = API.new
    begin
      resp = api.fetch_result(self.msm_id) # resp of Ripe is an array
      return if resp.length == 0 # result not available, do nothing
      resp = resp.first
      self.dst_addr = resp['dst_addr']
      self.endtime = Time.at(resp['endtime'])
      self.src = resp['src_addr']

      resp['result'].each do |r|
        hop = self.hops.create(:no => r['hop'])
        packet = r['result'].first
        hop.from = packet['from']
        hop.rtt = packet['rtt'] unless hop.from == '*'
        hop.save
      end

      self.available = true
      puts "available"
    rescue Exception => exc
      self.failed = true
      self.hops.destroy_all
      puts exc.message
    end
    self.save
  end

  def mark_failed
    self.failed = true
    self.save
  end
end
