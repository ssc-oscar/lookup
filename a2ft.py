import sys
import re
import gzip
from subprocess import Popen, PIPE
from oscar import *
from datetime import datetime

a2ft = {}
part = str(sys.argv[1])
f = gzip.GzipFile('/data/play/dkennard/a2ftFullP' + part + 'TEST1.s', 'w')
g = gzip.open('/da0_data/basemaps/gz/a2cFullP' + part + '.s', 'r')
print("reading a2cFullP" + part + ".s")
#command = 'zcat /data/basemaps/gz/a2cFullP' + str(i) + '.s'
#p1 = Popen(command, shell=True, stdout=PIPE)
#p2 = Popen('head -1000', shell=True, stdin=p1.stdout, stdout=PIPE)
#output = p2.communicate()[0]
first = True
j = 0
lines = g.readlines()
for line in lines:
	j += 1
	entry = str(line).rstrip('\n').split(';')
	author, commit_sha = entry[0], str(entry[1])
	if "\"\"" in author:
		continue
	if first:
		curr_author = author
		first = False
	non_empty = Commit_info(commit_sha).time_author
	if non_empty:
		time = non_empty[0]
	else:
		continue

	if author not in a2ft.keys():
		a2ft[author] = {}
	for file in Commit(commit_sha).changed_file_names:
		if file not in a2ft[author].keys() or time < a2ft[author][file]:
			a2ft[author][file] = time

	if author != curr_author or j == len(lines):
		print("writing " + curr_author + " into a2ftFullP" + part + ".s")
		if j == len(lines):
			curr_author = author
		f.write(curr_author)
		for file, time in a2ft[curr_author].items():
			f.write(';' + file + ';' + time)
		f.write('\n')
		curr_author = author
f.close()
g.close()
