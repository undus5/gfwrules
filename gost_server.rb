# gost server

require 'etc'
require 'yaml'

if Etc.getpwuid.uid == 0
  puts "Please use non-root user to execute."
  exit 1
end

PROJECT_ROOT = File.realpath(File.join(__dir__))
RELEASE_PATH = File.join(PROJECT_ROOT, 'dist')
if !Dir.exist?(RELEASE_PATH)
  Dir.mkdir(RELEASE_PATH)
end

filepath = "#{PROJECT_ROOT}/servers.yml"
if !File.exist?(filepath)
  File.write(filepath, File.read("#{ASSETS_PATH}/server_template.yml"))
end
servers = YAML.load(File.read(filepath))

servers.each do |server|
  gost_server_start = "#!/bin/bash\n\n"
  gost_server_start += "DOMAIN=#{server['server']}\n"
  gost_server_start += "USER=#{server['username']}\n"
  gost_server_start += "PASS=#{server['password']}\n"
  gost_server_start += "PORT=#{server['port']}\n\n"

  gost_server_start += "BIND_IP=0.0.0.0\n"
  gost_server_start += "CERT_DIR=/etc/letsencrypt\n"
  gost_server_start += "CERT=${CERT_DIR}/live/${DOMAIN}/fullchain.pem\n"
  gost_server_start += "KEY=${CERT_DIR}/live/${DOMAIN}/privkey.pem\n\n"

  gost_server_start += "docker run -d --name gost \\\n"
  gost_server_start += "    -v ${CERT_DIR}:${CERT_DIR}:ro \\\n"
  gost_server_start += "    --net=host ginuerzh/gost \\\n"
  gost_server_start += "    -L http2://${USER}:${PASS}@${BIND_IP}:${PORT}?cert=${CERT}&key=${KEY}"
  if server['middleware']
    gost_server_start += " \\\n    -F http://127.0.0.1:7890\n"
  end

  filepath = "#{RELEASE_PATH}/gost_server_#{server['alias']}_start.sh"
  File.write(filepath, gost_server_start)
  puts "#{filepath} saved."
end
