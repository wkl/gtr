require ENV["RAILS_ENV_PATH"]
loop {
  begin

    Traceroute.where(:submitted => false, :failed => false).each do |tr|
      puts "processing #{tr.uuid}..."

      # if too old (>10 min), marked failed
      if Time.now - tr.created_at > 600
        puts "marked failed"
        tr.mark_failed
        next
      end

      tr.submit

      sleep 0.1
    end

    probes = Rails.cache.fetch(:probes, :expires_in => 1800) do
      api = API.new
      api.fetch_probes()
    end

  rescue Exception => exc
    puts exc.message
  end

  sleep 1
}
