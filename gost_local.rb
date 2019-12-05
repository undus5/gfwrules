# gost local

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

gost_local_start = "#!/bin/bash\n\n"
gost_local_stop = "#!/bin/bash\n\n"
writable = false

servers.each_with_index do |server, index|
  if server["type"] == "https"
    writable = true
    container_name = "gost_local_#{server['name']}"
    local_port = 8444 + index

    gost_local_start += "DOMAIN=#{server['server']}\n"
    gost_local_start += "USER=#{server['username']}\n"
    gost_local_start += "PASS=#{server['password']}\n"
    gost_local_start += "PORT=#{server['port']}\n\n"

    gost_local_start += "docker run -d -p #{local_port}:#{local_port}"
    gost_local_start += " --name #{container_name} ginuerzh/gost"
    gost_local_start += " -L \"http://:#{local_port}\""
    gost_local_start += " -F \"https://${USER}:${PASS}@${DOMAIN}:${PORT}\"\n\n"

    gost_local_stop += "docker container rm -f #{container_name}\n"
  end
end

if writable
  filepath = "#{TEST_DIR}/gost_local_start.sh"
  File.write(filepath, gost_local_start)
  puts "#{filepath} saved."

  filepath = "#{TEST_DIR}/gost_local_stop.sh"
  File.write(filepath, gost_local_stop)
  puts "#{filepath} saved."
end
