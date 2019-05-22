require 'http'
require "json"
require "yaml"

LAN_IP_LIST_PATH = File.join(__dir__, "ip-lists/lan-ip-list.txt")
CHINA_IP_LIST_PATH = File.join(__dir__, "ip-lists/china-ip-list.txt")

PAC4SHADOWSOCKS_WINDOWS_TEMPLATE_PATH = File.join(__dir__, "pac-dependencies/pac4shadowsocks_windows-template.js")
PAC4SHADOWSOCKS_WINDOWS_RELEASE_PATH = File.join(__dir__, "releases/pac4shadowsocks_windows.js")

PAC4SWITCHYOMEGA_TEMPLATE_PATH = File.join(__dir__, "pac-dependencies/pac4switchyomega-template.js")
PAC4SWITCHYOMEGA_RELEASE_PATH = File.join(__dir__, "releases/pac4switchyomega.js")

SHADOWSOCKS_CONFIG_TEMPLATE_PATH = File.join(__dir__, "surge3-dependencies/shadowsocks-config-example.json")
SURGE3_CONFIG_TEMPLATE_PATH = File.join(__dir__, "surge3-dependencies/surge3-template.txt")
SURGE3_CONFIG_RELEASE_PATH = File.join(__dir__, "releases/surge3.conf")

CLASH_CONFIG_RELEASE_PATH = File.join(__dir__, "releases/clash.yml")

SURGE3_CONFIG_TEMP_PATH = File.join(__dir__, "surge3.conf")
CLASH_CONFIG_TEMP_PATH = File.join(__dir__, "clash.yml")

def calculate_subnet_mask(subnet_prefix_size)
  binary_str_1 = "1" * subnet_prefix_size
  binary_str_0 = "0" * (32 - subnet_prefix_size)
  binary_str = binary_str_1 + binary_str_0

  mask_str = ""
  slice_length = 8
  4.times do |i|
    mask_str += binary_str.slice(i * slice_length, 8).to_i(2).to_s
    mask_str += "." if i < 3
  end
  mask_str
end

begin
  filename = ARGV[0].nil? ? SHADOWSOCKS_CONFIG_TEMPLATE_PATH : ARGV[0]
  ss_config = JSON.parse(File.read(filename))
  raise "" if ss_config["server"].nil?
rescue JSON::ParserError, RuntimeError
  puts "Error: Invalid shadowsocks config file."
end

url = "https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt"
puts "Downloading #{url}"
response = HTTP.get(url)
File.write(CHINA_IP_LIST_PATH, response.to_s) if response.code == 200

lan_ip_list_raw  = File.read(LAN_IP_LIST_PATH)
china_ip_list_raw = File.read(CHINA_IP_LIST_PATH)

# ---
puts "Generating PAC files..."
ip_list_arr = []
(lan_ip_list_raw + china_ip_list_raw).each_line do |str|
  ip_arr = str.split('/')
  ip_arr[1] = calculate_subnet_mask(ip_arr[1].to_i)
  ip_list_arr.push(ip_arr)
end

ip_list_str = ip_list_arr.to_s
ip_list_str.gsub!("[[", "[\n    [")
ip_list_str.gsub!("],", "],\n   ")
ip_list_str.gsub!("]]", "]\n]")

pac4shadowsocks_windows_str = File.read(PAC4SHADOWSOCKS_WINDOWS_TEMPLATE_PATH)
File.write(PAC4SHADOWSOCKS_WINDOWS_RELEASE_PATH, pac4shadowsocks_windows_str.gsub("__IPLIST__", ip_list_str))
puts "#{PAC4SHADOWSOCKS_WINDOWS_RELEASE_PATH} saved."

pac4switchyomega_str = File.read(PAC4SWITCHYOMEGA_TEMPLATE_PATH)
File.write(PAC4SWITCHYOMEGA_RELEASE_PATH, pac4switchyomega_str.gsub("__IPLIST__", ip_list_str))
puts "#{PAC4SWITCHYOMEGA_RELEASE_PATH} saved."

# ---
puts "Generating Surge3 config file..."
ip_rules = ""
china_ip_list_raw.each_line do |str|
  rule = "IP-CIDR,#{str.strip},DIRECT\n"
  ip_rules += rule
end
ip_rules.rstrip!

config_content = File.read(SURGE3_CONFIG_TEMPLATE_PATH)
config_content.gsub!("__IPRULES__", ip_rules)

config_content.gsub!("__SERVER__", ss_config["server"])
config_content.gsub!("__PORT__", ss_config["server_port"].to_s)
config_content.gsub!("__ENCRYPTION__", ss_config["method"])
config_content.gsub!("__PASSWORD__", ss_config["password"])

if ARGV[0].nil?
  File.write(SURGE3_CONFIG_RELEASE_PATH, config_content)
  puts "#{SURGE3_CONFIG_RELEASE_PATH} saved."
else
  File.write(SURGE3_CONFIG_TEMP_PATH, config_content)
  puts "#{SURGE3_CONFIG_TEMP_PATH} saved."
end

# ---
puts "Generating clash config file..."
ip_rules = ["DOMAIN-SUFFIX,local,DIRECT"]
(lan_ip_list_raw + china_ip_list_raw).each_line do |str|
  rule = "IP-CIDR,#{str.strip},DIRECT"
  ip_rules.push(rule)
end
ip_rules.push("MATCH,SS")

clash_config = {
  "port" => 7890,
  "socks-port" => 7891,
  "redir-port" => 0,
  "allow-lan" => false,
  "mode" => "Rule",
  "log-level" => "info",
  "external-controller" => "0.0.0.0:9090",
  "secret" => "",
  "Proxy" => [
    {
      "type" => "ss",
      "server" => ss_config["server"],
      "port" => ss_config["server_port"],
      "password" => ss_config["password"],
      "cipher" => ss_config["method"],
      "name" => "SS"
    }
  ],
  "Proxy Group" => [
    {
      "name" => "Proxy",
      "type" => "select",
      "proxies" => ["SS"] 
    }
  ],
  "Rule" => ip_rules
}

if ARGV[0].nil?
  File.write(CLASH_CONFIG_RELEASE_PATH, clash_config.to_yaml.gsub("---\n", ""))
  puts "#{CLASH_CONFIG_RELEASE_PATH} saved."
else
  File.write(CLASH_CONFIG_TEMP_PATH, clash_config.to_yaml.gsub("---\n", ""))
  puts "#{CLASH_CONFIG_TEMP_PATH} saved."
end