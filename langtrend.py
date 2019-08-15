import sys
import re
from subprocess import check_output, PIPE, Popen
from scipy import stats
import numpy as np
import pprint


part = str(sys.argv[1])
output = check_output('zcat a2LFullP' + part + '.s', shell=True)
dict = {}
lines = str(output).split('\\n')
for line in lines:
	if line == "\'":
		break
	output = str(line).rstrip('\\n').split(';')
	author = output[0]
	parse_years = re.findall("year20[0-1][0-9]", ";".join(output[0:]))
	years = []
	for year in parse_years:
		year = year.replace('year', '')
		years.append(year)
	non_consec = False
	for i in range(len(sorted(years)) - 1):
		if int(years[i+1]) - int(years[i]) > 1:
			non_consec = True
			break
	if non_consec:
		continue

	dict[author] = {}
#	print(output)
	for year in years:
		lookup_year = 'year' + year
		i = output.index(lookup_year)
		num_langs = int(output[i+1])
		if len(years) == 1 and num_langs == 0:
			del(dict[author])
			break
		if num_langs == 0:
			continue
		dict[author][year] = {}
		for j in range(1, 2*num_langs + 1, 2):
			lang = output[i+j+1]
			num_files = int(output[i+j+2])
			dict[author][year][lang] = num_files

dict2 = dict.copy()

for author in dict2:
	for year in sorted(dict2[author]):
		if sum(dict2[author][year].values()) < 100:
			del(dict[author][year])

	if len(dict2[author].keys()) < 5:
		del(dict[author])

for author in dict:
	value_table = []
	lang_list = []
	years = sorted(dict[author].keys())
	for year in years:
		for lang, num_files in dict[author][year].items():
			if lang not in lang_list:
				lang_list.append(lang)
	print("----------------------------------")
	print(author)
	pp = pprint.PrettyPrinter(indent=2)
	pp.pprint(dict[author])
	for language in lang_list:
		pfactors = []
		p_diffs = []
		lang_percs = []
		print("    pfactors for " + language + " language")
		for year in years:
			cnc = ""
			if years.index(year) == len(years) - 1:
				if language not in dict[author][year]:
					fraction = str(0) + "/" + str(sum(dict[author][year].values()))
					lang_percs.append((year, 0.0, fraction))
				else:
					lang_count = dict[author][year][language]
					percentage = "{0:.2%}".format(round(lang_count / sum(dict[author][year].values()),2))
					fraction = str(lang_count) + "/" + str(sum(dict[author][year].values()))
					lang_percs.append((year, percentage, fraction))
				break
			next_year = str(int(year) + 1)
			while next_year not in years:
				next_year = str(int(next_year) + 1)
			y1 = []
			y2 = []
			ys = []
			if language not in dict[author][year]:
				fraction = str(0) + "/" + str(sum(dict[author][year].values()))
				lang_percs.append((year, 0.0, fraction))
			else:
				lang_count = dict[author][year][language]
				percentage = "{0:.2%}".format(round(lang_count / sum(dict[author][year].values()),2))
				fraction = str(lang_count) + "/" + str(sum(dict[author][year].values()))
				lang_percs.append((year, percentage, fraction))
			if language not in dict[author][year].keys(): 
				y1.append(0)
				y1.append(sum(dict[author][year].values())) 
			else:
				y1.append(dict[author][year][language])
				y1.append(sum(dict[author][year].values()) - dict[author][year][language])
			ys.append(y1)
			if language not in dict[author][next_year].keys():
				y2.append(0)
				y2.append(sum(dict[author][next_year].values())) 
			else:
				y2.append(dict[author][next_year][language])
				y2.append(sum(dict[author][next_year].values()) - dict[author][next_year][language])
			ys.append(y2)
			if (ys[0][1] == 0 and ys[1][1] == 0) or (ys[0][0] == 0 and ys[1][0] == 0):
				continue
			chi_2, pfactor, dof, array = stats.chi2_contingency(ys)
			pfactors.append(pfactor)
			if pfactor < 0.001:
				cnc = "rise/drop"
			else:
				cnc = "no change"
			print("        " + year + "--" + next_year + " pfactor == " + str(pfactor) + "  " + cnc)
		pp.pprint(lang_percs)
		'''
		if len(pfactors) > 1:
			for i in range(len(pfactors) - 1):
				p_diffs.append(pfactors[i+1] - pfactors[i])
			print("            " + language + " p_diffs:", end=" ")
			print(p_diffs)
		'''
print(len(dict.keys()))
