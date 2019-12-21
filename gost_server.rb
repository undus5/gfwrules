# gost server

require 'etc'

if Etc.getpwuid.uid == 0
  puts "Please use non-root user to execute."
  exit 1
end

PROJECT_ROOT = File.realpath(File.join(__dir__))
ASSETS_DIR = File.join(PROJECT_ROOT, 'assets')
TEST_DIR = File.join(PROJECT_ROOT, 'test')
Dir.mkdir(TEST_DIR) if !Dir.exist?(TEST_DIR)

script = "#!/bin/bash\n\n"
script += "DOMAIN=\n"
script += "USER=\n"
script += "PASS=\n"
script += "PORT=\n\n"

script += "BIND_IP=0.0.0.0\n"
script += "CERT_DIR=/etc/letsencrypt/live/${DOMAIN}\n"
script += "CERT=${CERT_DIR}/fullchain.pem\n"
script += "KEY=${CERT_DIR}/privkey.pem\n\n"

script += "gost -L \"http2://${USER}:${PASS}@${BIND_IP}:${PORT}?cert=${CERT}&key=${KEY}\""

script += "\n\n# -F \"http://127.0.0.1:7890\""
script += "\n# -F \"https://${USER}:${PASS}@0.0.0.0:${PORT}\""

filepath = "#{TEST_DIR}/gost_server_start.sh"
File.write(filepath, script)
puts "#{filepath} saved."
