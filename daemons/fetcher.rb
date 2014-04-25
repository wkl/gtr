require ENV["RAILS_ENV_PATH"]
loop {
  begin

    Traceroute.where(:available => false, :submitted => true, :failed => false).each do |tr|
      puts "fetching #{tr.uuid} (#{tr.msm_id})..."

      # if too old (>10 min), marked failed, can prevent abuse
      if Time.now - tr.created_at > 600
        puts "marked failed"
        tr.mark_failed
        next
      end

      tr.fetch

      sleep 0.1
    end

  rescue Exception => exc
    puts exc.message
  end

  sleep 5
}
