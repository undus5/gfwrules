require "etc"
require "json"
require "resolv"

IPSET_NAME = "china-ip-and-lan"
CHAIN_NAME = "SHADOWSOCKS"

def ipset_exists?
  result = system("ipset list #{IPSET_NAME}", err: File::NULL)
  if result.nil?
    puts "Please install 'ipset' package first."
    exit 127
  end
  result
end

def chain_exists?
  system("iptables -t nat -L #{CHAIN_NAME}", err: File::NULL)
end

def initiated?
  ipset_exists? || chain_exists?
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
  system("iptables -t nat -N #{CHAIN_NAME}")
  ss_server = Resolv.getaddress(ss_config["server"])
  system("iptables -t nat -A #{CHAIN_NAME} -d #{ss_server} -j RETURN")
  system("iptables -t nat -A #{CHAIN_NAME} -p tcp -m set --match-set #{IPSET_NAME} dst -j RETURN")
  system("iptables -t nat -A #{CHAIN_NAME} -p tcp -j REDIRECT --to-port #{ss_config["local_port"].to_s}")
end

def rules_up?
  system("iptables -t nat -C OUTPUT -p tcp -j #{CHAIN_NAME}", err: File::NULL)
end

def rules_up
  system("iptables -t nat -A OUTPUT -p tcp -j #{CHAIN_NAME}") if !rules_up?
end

def rules_down
  system("iptables -t nat -D OUTPUT -p tcp -j #{CHAIN_NAME}") if rules_up?
end

def purge_rules
  rules_down
  system("iptables -t nat -F #{CHAIN_NAME}")
  system("iptables -t nat -X #{CHAIN_NAME}")
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
    exit 99
  end

  begin
    ss_config = JSON.parse(File.read(File.expand_path(ARGV[1])))
    raise "" if ss_config["server"].nil?
  rescue JSON::ParserError, RuntimeError
    puts "Error: Invalid shadowsocks config file."
  end

  if initiated?
    puts "Already initiated."
    exit 99
  end

  puts "It may take a few minutes..."
  create_ipset
  setup_rules(ss_config)
  rules_up
  puts "Done\n"
when "update"
  if !initiated?
    puts "Please run `sudo ruby iptables.rb init` first."
    exit 99
  end
  destroy_ipset
  create_ipset
when "up"
  if !initiated?
    puts "Please run `sudo ruby iptables.rb init` first."
    exit 99
  end
  rules_up
when "down"
  if !initiated?
    puts "Please run `sudo ruby iptables.rb init` first."
    exit 99
  end
  rules_down
when "purge"
  if !initiated?
    puts "Please run `sudo ruby iptables.rb init` first."
    exit 99
  end
  purge_rules
else
  puts "Usage: sudo ruby iptables.rb [init|up|down|update|purge]"
end


