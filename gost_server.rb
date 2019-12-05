# gost server

require 'etc'
require 'yaml'

if Etc.getpwuid.uid == 0
  puts "Please use non-root user to execute."
  exit 1
end

PROJECT_ROOT = File.realpath(File.join(__dir__))
ASSETS_DIR = File.join(PROJECT_ROOT, 'assets')
TEST_DIR = File.join(PROJECT_ROOT, 'test')
Dir.mkdir(TEST_DIR) if !Dir.exist?(TEST_DIR)
SERVER_EXAMPLE = File.join(ASSETS_DIR, "server_example.yml")
SERVER_TEST = File.join(TEST_DIR, "servers.yml")
if !File.exist?(SERVER_TEST)
  File.write(SERVER_TEST, File.read(SERVER_EXAMPLE))
end

servers = YAML.load(File.read(SERVER_TEST))

servers.each do |server|
  if server["type"] == "https"
    gost_server_start = "#!/bin/bash\n\n"
    gost_server_start += "DOMAIN=#{server['server']}\n"
    gost_server_start += "USER=#{server['username']}\n"
    gost_server_start += "PASS=#{server['password']}\n"
    gost_server_start += "PORT=#{server['port']}\n\n"

    gost_server_start += "BIND_IP=0.0.0.0\n"
    gost_server_start += "CERT_DIR=/etc/letsencrypt\n"
    gost_server_start += "CERT=${CERT_DIR}/live/${DOMAIN}/fullchain.pem\n"
    gost_server_start += "KEY=${CERT_DIR}/live/${DOMAIN}/privkey.pem\n\n"

    gost_server_start += "docker run -d --name gost"
    gost_server_start += " -v ${CERT_DIR}:${CERT_DIR}:ro"
    gost_server_start += " --net=host ginuerzh/gost"
    gost_server_start += " -L \"http2://${USER}:${PASS}@${BIND_IP}:${PORT}?cert=${CERT}&key=${KEY}\""
    if server['forward']
      gost_server_start += " -F \"http://127.0.0.1:7890\""
    end

    filepath = "#{TEST_DIR}/gost_server_#{server['name']}_start.sh"
    File.write(filepath, gost_server_start)
    puts "#{filepath} saved."
  end
end

gost_server_stop = "#!/bin/bash\n\n"
gost_server_stop += "docker container rm -f gost\n"

filepath = "#{TEST_DIR}/gost_server_stop.sh"
File.write(filepath, gost_server_stop)
puts "#{filepath} saved."
