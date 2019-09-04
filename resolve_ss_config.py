import sys
import json

ss = json.loads(open(sys.argv[1], 'r').read())

if sys.argv[2] == 'server':
  print(ss['server'])
elif sys.argv[2] == 'local_port':
  print(ss['local_port'])
else:
  raise Exception
