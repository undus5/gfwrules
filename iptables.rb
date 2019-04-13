require "etc"
require "yaml"
require "json"
require "resolv"

IPSET_NAME = "china-ip-and-lan"

def ipset_exists?
  result = system("ipset list #{IPSET_NAME}")
  raise "Please install 'ipset' package first." if result.nil?
  result
end

def destroy_ipset
  system("ipset destroy #{IPSET_NAME}", err: File::NULL)
end

def create_ipset
  system("ipset create #{IPSET_NAME} hash:net")

  file_content = File.read("LAN-IP-list.txt")
  file_content += File.read("china-ip-list.txt")
  file_content.each_line do |str|
    system("ipset add #{IPSET_NAME} #{str.strip}")
  end
end

def setup_rules(ss_config)
  exit 1 if !system("iptables -t nat -N SHADOWSOCKS")
  ss_server = Resolv.getaddress(ss_config["server"])
  system("iptables -t nat -A SHADOWSOCKS -d #{ss_server} -j RETURN")
  system("iptables -t nat -A SHADOWSOCKS -p tcp -m set --match-set #{IPSET_NAME} dst -j RETURN")
  system("iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-port #{ss_config["local_port"].to_s}")
end

def rules_up?
  system("iptables -t nat -C OUTPUT -p tcp -j SHADOWSOCKS", err: File::NULL)
end

def rules_up
  system("iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS") if !rules_up?
end

def rules_down
  system("iptables -t nat -D OUTPUT -p tcp -j SHADOWSOCKS") if rules_up?
end

def purge_rules
  rules_down
  system("iptables -t nat -F SHADOWSOCKS")
  system("iptables -t nat -X SHADOWSOCKS")
  destroy_ipset
end

if Etc.getpwuid.uid != 0
  puts "You need to run this script as root or using sudo"
  exit 1
end

case ARGV[0]
when "init"
  if ARGV[1].nil?
    puts "Usage: sudo ruby iptables.rb init 'your-shadowsocks-config-filename'"
    exit 1
  end

  puts "It may take a few minutes..."

  begin
    ss_config = JSON.parse(File.read(File.expand_path(ARGV[1])))
    raise "" if ss_config["server"].nil?
  rescue JSON::ParserError, RuntimeError
    puts "Error: Invalid shadowsocks config file."
  end

  destroy_ipset
  create_ipset
  setup_rules(ss_config)
  rules_up

  puts "Done\n"
when "update"
  destroy_ipset
  create_ipset
when "up"
  rules_up
when "down"
  rules_down
when "purge"
  purge_rules
else
end


