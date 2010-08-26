require 'rubygems'
require 'mmap'
require 'eventmachine'
require 'fileutils'

File.delete("./storage") if File.exists?("./storage")
FileUtils.touch "./storage"

module CacheR
  @@commands = {"put" => :handle_put, "get" => :handle_get}
  @@keymap = {}
  @@mmap_store = Mmap.new("./storage", "rw")

  def receive_data(data)
    t = Time.now
    cmd, body = data.chomp.split("::", 2)
    if @@commands.has_key?(cmd) 
      send_data self.send(@@commands[cmd], body)
    else
      send_data "ERR::Unrecognized Command"
    end
    send_data "aaaa"
    total = Time.now - t
    puts "request took #{total} to process"
  end

  def handle_put(body)
    key, msg = body.split("::", 2)
    if key && msg
      if @@keymap[key]
        if @@keymap[key][1] >= msg.size
          @@mmap_store[@@keymap[key][0], msg.size] = msg
          @@keymap[key][1] = msg.size
        end
      else
        @@keymap[key] = [@@mmap_store.size, msg.size]
        @@mmap_store << msg
      end
      "OK"
    else
      "ERR::Invalid Request"
    end
  end

  def handle_get(body)
    if @@keymap[body]
      @@mmap_store[@@keymap[body][0], @@keymap[body][1]]
    else
      "ERR::Invalid Key"
    end
  end
end

EventMachine::run do
  EventMachine::start_server "127.0.0.1", 10101, CacheR
  puts "Started the CacheR Server"
end
