module ApiConsumerService
  include HTTParty
  def self.get_metrics
    begin
      response = get('https://cdn.glitch.me/760886e0-5f1f-4216-9a2e-0e0c7c7797eb%2Fbuilds.json')
      return true, {lead_time:calculate_lead_time(response),failed_percentage:calculate_failed(response),downtime_average:calculate_downtime(response)}
      
    rescue HTTParty::Error => e
      puts "Error al obtener datos"
      puts e.inspect
      return false, { errors: ["Error al obtener datos"]}
    end
  end

  def self.calculate_failed(builds)
    total = builds.length
    failed_count = builds.select{|i|i["result"]!="SUCCESS"}.length
    failed_percentage = 100 * failed_count / total
  end

  def self.calculate_lead_time(builds)
    total = builds.reduce(0){|acc,i|acc + i["duration"]}
    ms = total / builds.length
    ms_to_time(ms)
  end

  def self.calculate_downtime(builds)
    previous_timestamp = nil
    sorted = builds.sort_by{|i| i["id"].to_i}
    failed = false
    aux_time = 0
    times = []
    sorted.each do |i|
      if i["result"] == "SUCCESS" && !failed
        next
      elsif i["result"] == "SUCCESS" && failed
        aux_time = i["timestamp"] - previous_timestamp
        times.push(aux_time)
        #previous_timestamp = i["timestamp"]
        failed = false
      else
        if !failed
          previous_timestamp = i["timestamp"]
        end
        failed = true
      end
    end
    result = times.length > 0 ? (times.reduce(0){|acc,t| acc + t  } / times.length) : 0
    #uts times
    ms_to_time(result)
  end

  def self.ms_to_time(ms)
    if((aux = ms / 1000.to_f) > 60)
      if((aux = aux / 60) > 60)
        if((aux = aux / 60) > 60)
          result = aux / 24
          unit = "days"
        else
          result = aux
          unit = "hours"
        end
      else
        result = aux
        unit = "minutes"
      end
    else
      result = ms / 1000
      unit = "seconds"
    end
    return result, unit
  end
end