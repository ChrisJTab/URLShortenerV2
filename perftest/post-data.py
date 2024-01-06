#!/usr/bin/python3

import random, string, sys

PORT = 8888
'''
Usage: ./writeTest.py <URL> <num_hosts> <jobs_per_host>

Generates num_hosts*jobs_per_host random GET and PUT requests to the URL
and writes them to read_commands.txt and write_commadns.txt respectively.
''' 
def main(host, num_hosts, jobs_per_host):
	output_file = 'post-data.txt'
	with open(output_file, 'w') as f:
		for i in range(int(num_hosts)*int(jobs_per_host)):
			longResource = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(100))
			shortResource = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))

			request=f"short="+shortResource+"\&long="+longResource

			f.write(request+"\n")

if __name__=='__main__':
  if len(sys.argv) != 4:
    print("USAGE: writeTest.py <URL> <num_hosts> <jobs_per_host>")
  else: 
    main(sys.argv[1], sys.argv[2], sys.argv[3])