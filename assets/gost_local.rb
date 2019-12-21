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

start_script = "#!/bin/bash\n\n"
stop_script = "#!/bin/bash\n\n"
writable = false

servers.each_with_index do |server, index|
  if server["type"] == "https"
    writable = true
    app_name = "gost_local_#{server['name']}"
    local_port = 8444 + index

    start_script += "DOMAIN=#{server['server']}\n"
    start_script += "USER=#{server['username']}\n"
    start_script += "PASS=#{server['password']}\n"
    start_script += "PORT=#{server['port']}\n\n"

    start_script += "pm2 start gost --name #{app_name} -- -L \"http://:#{local_port}\""
    start_script += " -F \"https://${USER}:${PASS}@${DOMAIN}:${PORT}\"\n\n"

    stop_script += "pm2 delete #{app_name}\n"
  end
end

if writable
  filepath = "#{TEST_DIR}/gost_local_start.sh"
  File.write(filepath, start_script)
  puts "#{filepath} saved."

  filepath = "#{TEST_DIR}/gost_local_stop.sh"
  File.write(filepath, stop_script)
  puts "#{filepath} saved."
end
