package "ntp" do
  retries 2
end

service "ntp" do
  action [:enable, :start]
end
