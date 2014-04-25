class Traceroute < ActiveRecord::Base
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
end
