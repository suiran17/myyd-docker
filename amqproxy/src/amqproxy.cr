require "./amqproxy/version"
require "./amqproxy/server"
require "option_parser"
require "uri"

listen_address = ENV["LISTEN_ADDRESS"]? || "localhost"
listen_port = ENV["LISTEN_PORT"]? || 5673
log_level = Logger::INFO
p = OptionParser.parse do |parser|
  parser.banner = "Usage: amqproxy [options] [amqp upstream url]"
  parser.on("-l ADDRESS", "--listen=ADDRESS", "Address to listen on (default is all)") { |p| listen_address = p }
  parser.on("-p PORT", "--port=PORT", "Port to listen on (default: 5673)") { |p| listen_port = p.to_i }
  parser.on("-d", "--debug", "Verbose logging") { |d| log_level = Logger::DEBUG }
  parser.on("-h", "--help", "Show this help") { puts parser.to_s; exit 0 }
  parser.on("-v", "--version", "Display version") { puts AMQProxy::VERSION.to_s; exit 0 }
  parser.invalid_option { |arg| abort "Invalid argument: #{arg}" }
end

upstream = ARGV.shift? || ENV["AMQP_URL"]?
abort p.to_s if upstream.nil?

u = URI.parse upstream
abort "Invalid upstream URL" unless u.host
default_port =
  case u.scheme
  when "amqp" then 5672
  when "amqps" then 5671
  else abort "Not a valid upstream AMQP URL, should be on the format of amqps://hostname"
  end
port = u.port || default_port
tls = u.scheme == "amqps"

server = AMQProxy::Server.new(u.host || "", port, tls, log_level)

shutdown = -> (s : Signal) do
  server.close
  exit 0
end
Signal::INT.trap &shutdown
Signal::TERM.trap &shutdown

server.listen(listen_address, listen_port.to_i)
