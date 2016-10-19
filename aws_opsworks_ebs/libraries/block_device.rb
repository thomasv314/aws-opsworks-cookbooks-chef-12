module BlockDevice
  def self.wait_for(device, timeout = 300)
    sleep_time = 10
    time_elapsed = 0

    while time_elapsed <= timeout
      break if File.blockdev?(device)

      Chef::Log.info("device #{device} not ready - waiting")
      sleep sleep_time
      time_elapsed += sleep_time
    end

    Chef::Log.info("Waiting for device #{device} becoming ready timed out.") if time_elapsed > timeout
  end
end
