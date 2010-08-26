require 'net/telnet'

actor = ARGV[0]
telnet = Net::Telnet::new("Host" => "127.0.0.1", "Port" => 10101, "Prompt" => /aaaa/)
10000.times do |t|
  begin
    telnet.cmd("put::key#{actor}#{t}::Message #{actor}-#{t}") {|r| puts "#{t} #{r}"}
  rescue
  end
  sleep 0.25
end
  
