#!/usr/bin/python3

import random, string, sys
 
def main(host, num_hosts, jobs_per_host):
	output_file = 'write_commands.txt'
	output_file2 = 'read_commands.txt'
	f2 = open(output_file2, 'w')
	with open(output_file, 'w') as f:
		for i in range(int(num_hosts)*int(jobs_per_host)):
			longResource = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(100))
			shortResource = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))

			request=f"http://{host}/?short="+shortResource+"\&long="+longResource

			curl_command = f"curl -s -X PUT {request} > /dev/null"
			# subprocess.call(["curl", "-X", "PUT", request], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
			f.write(curl_command+"\n")
			f2.write(f"curl -s -X GET http://{host}/{shortResource} > /dev/null\n")
if __name__=='__main__':
  if len(sys.argv) != 4:
    print("USAGE: writeTest.py <URL> <num_hosts> <jobs_per_host>")
  else: 
    main(sys.argv[1], sys.argv[2], sys.argv[3])
