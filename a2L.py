import sys
import re
import gzip
from subprocess import Popen, PIPE
from oscar import *
from datetime import datetime

a2L = {}

part = str(sys.argv[1])
f = gzip.GzipFile('/data/play/dkennard/a2LFullP' + part + '.s', 'w')
g = gzip.open('/da0_data/basemaps/gz/a2cFullP' + part + '.s', 'r')
print("reading a2cFullP" + part + ".s")
line = g.readline()
curr_author = ""
specifier = 'year'

while line != "":
	entry = str(line).rstrip('\n').split(';')
	author = entry[0]
	if curr_author == author:
		line = g.readline()
		continue

	if "\"\"" in author:
		line = g.readline()
		continue

	curr_author = author

	a2L[author] = {}
	file_times = Author(author).file_times
	for j in range(0,len(file_times),2):
		try:
			year = str(datetime.fromtimestamp(float(file_times[j+1]))).split(" ")[0].split("-")[0]
		#have to skip years either in the 20th century or somewhere far in the future
		except ValueError:
			continue
		#in case the last file listed doesn't have a time
		except IndexError:
			break
		year = specifier + year
		if year not in a2L[author]:
			a2L[author][year] = []
		a2L[author][year].append(file_times[j])

	for year, files in a2L[author].items():
		build_list = []
		for file in files:
			la = "other"
			if re.search("\.(js|iced|liticed|iced.md|coffee|litcoffee|coffee.md|ts|cs|ls|es6|es|jsx|sjs|co|eg|json|json.ls|json5)$",file):
				la = "js"
			elif re.search("\.(py|py3|pyx|pyo|pyw|pyc|whl|ipynb)$",file):
				la = "py"
			elif re.search("(\.[Cch]|\.cpp|\.hh|\.cc|\.hpp|\.cxx)$",file):
				la = "c"
			elif re.search("(\.Rd|\.[Rr]|\.Rprofile|\.RData|\.Rhistory|\.Rproj|^NAMESPACE|^DESCRIPTION|\/NAMESPACE|\/DESCRIPTION)$",file):
				la = "r"
			elif re.search("\.(sh|shell|csh|zsh|bash|pbs|bat|BAT)$",file):
				la = "sh"
			elif re.search("\.(pl|PL|pm|pod|perl)$",file):
				la = "pl"
			elif re.search("\.(html|css)$",file):
				la = "html"
			elif re.search("(\.java|\.iml|\.class)$",file):
				la = "java"
			elif re.search("\.scala$",file):
				la = "scala"
			elif re.search("\.(rs|rlib|rst)$",file):
				la = "rust"
			elif re.search("\.go$",file):
				la = "go"
			elif re.search("\.(f[hi]|[fF]|[fF]77|[fF]9[0-9]|fortran|forth)$", file):
				la = "f"
			elif re.search("\.(rb|erb|gem|gemspec)$", file):
				la = "rb"
			elif re.search("\.php$", file):
				la = "php"
			elif re.search("\.cs$", file):
				la = "cs"
			elif re.search("\.swift$", file):
				la = "swift"
			elif re.search("\.erl$", file):
				la = "erl"
			elif re.search("\.(sql|sqllite|sqllite3|mysql)$", file):
				la = "sql"
			elif re.search("\.(el|lisp|elc)$", file):
				la = "lsp"
			elif re.search("\.lua$", file):
				la = "lua"
			elif re.search("\.jl$", file):
				la = "jl"
			elif re.search("\.(o|a|so|exe|bin)$", file):
				la = "obj"
			elif re.search("\.(tex|bib|sty|cls|ttf|TTF)$", file):
				la = "tex"
			elif re.search("(\.md|\.html|\.xml|\.css|README|AUTHORS|TODO|CHANGELOG|changelog|ChangeLog|COPYING)$", file):
				la = "markup"
			elif re.search("(Makefile|Dockerfile|build\.xml|BUILD|\.cmake|Makefile.in|rake|CMakeLists\.txt|\.TXT|\.m4|\.am|vcproj|vcxproj|Imakefile)$", file):
				la = "build"
			elif re.search("\.(txt|ps|eps|pdf|org|pptx|doc|ppt|xls|odp|odf|jpg|JPG|jpeg|png|pgm|gif|tif|tiff)$", file):
				la = "doc"
				
			build_list.append(la)
	
		a2L[author][year] = {}
		used_langs = []
		build_dict = {}
		for lang in build_list:
			if lang not in used_langs:
				lang_count = build_list.count(lang)
				build_dict[lang] = lang_count
				used_langs.append(lang)
		a2L[author][year] = build_dict

	print("writing " + author + " into a2LFullP" + part + ".s")
	f.write(author)
	for year, lang_percs in sorted(a2L[author].items(), key = lambda kv: kv[0]):
		f.write(';' + year + ';' + str(len(a2L[author][year].keys())))
		for lang, count in a2L[author][year].items():
			f.write(';' + lang + ';' + str(count))
	f.write('\n')
	line = g.readline()
f.close()
g.close()
