import pymongo
import re
import sys
from oscar import *
import subprocess

badProjects = {
  'bb_fusiontestaccount_fuse-2944': '32400A',
  'bb_fusiontestaccount_fuse1999v2': '34007A', 
  'octocat_Spoon-Knife': 'forking tutorial, 41176A', 
  'cirosantilli_imagine-all-the-people': 'Commit email scraper, 389993A',
  'marcelstoer_nodemcu-custom-build': '97994A',
  'jasperan_github-utils': '4394779C', 
  'avsm_ocaml-ci.logs': '4283368C'}

badAuthors = { 
  'one-million-repo <mikigal.acc@gmail.com>': "1M commits", 
  'scraped_page_archive gem 0.5.0 <scraped_page_archive-0.5.0@scrapers.everypolitician.org>': "4243985C", 
  'Your Name <you@example.com>': "1829654C",
  'Auto Pilot <noreply@localhost>': "2063212C",
  'GitHub Merge Button <merge-button@github.com>': "109778A",
  '= <=>': "190490A",
  'greenkeeper[bot] <greenkeeper[bot]@users.noreply.github.com>': "2067354C", 
  'Google Code Exporter <GoogleCodeExporter@users.noreply.github.com>': "277+K projects",
  'datakit <datakit@docker.com>': "4400778 commits"}

doPrj = False
doFiles = False
doBlobs = True

client = pymongo.MongoClient("mongodb://da1.eecs.utk.edu/")

db = client["WoC"]
col = db["users"]
users = col.find({})

########################
## get author ids for each user
input = {}
for user in users:
	input[user['_id']] = []
	for selectId in user['selectedIds']:
		if isinstance(selectId, basestring):
			input[user['_id']].append(selectId)
		elif isinstance(selectId, dict):
			input[user['_id']].append(selectId['id'])
'''
for key, val in input.items():
	print(key),
	print(":"),
	print(val)
'''

#######################
# get torvalds paths for a user
a2tr = {}
for user in input.keys():
	pa = {}
	connected = False
	for author_id in input[user]:
		#check for non-empty
		if Author(author_id.encode('utf-8')).torvald:
			path = []
			path.append(author_id.encode('utf-8'))
			for item in Author(author_id.encode('utf-8')).torvald:
				path.append(item)
			pa[len(path)] = ";".join(path)
			connected = True
		
	if connected:
		ml = sorted(pa.keys())[0]
		a2tr[user] = pa[ml]
'''
for key, val in a2tr.items():
	print(key),
	print(":"),
	print(val)
'''
#######################
## get projects for a user
a2p = {}
for user in input.keys():
	a2p[user] = []
	for author_id in input[user]:
		projects = Author(author_id.encode('utf-8')).project_names
		for proj in projects:
			if proj in badProjects.keys():
				continue
			if proj not in a2p[user]:
				a2p[user].append(proj)
'''
for key, val in a2p.items():
	print(key),
	print(":"),
	print(val)
'''

#######################
## place to store the unicode author names of a user as strings. 
str_version = {}
for user in input.keys():
	str_version[user] = []
	for name in input[user]:
		name = name.encode('utf-8')
		str_version[user].append(name)

#######################
## get all authors for projects user worked on
gA = {}		## global authors
u2a = {}
for user in input.keys():
	p2a = {}
	for proj in a2p[user]:
		if proj in badProjects.keys() or proj in p2a.keys():
			continue 
		p2a[proj] = []
		for author in Project(proj).author_names:
			if author in str_version[user]:
				continue
			p2a[proj].append(author)
			if author not in gA.keys():
				gA[author] = []
			gA[author].append(proj)
	u2a[user] = p2a

'''
for key, val in u2a.items():
	print(key),
	print(":"),
	print(val)
'''
'''
for key, val in gA.items():
	print(key),
	print(":"),
	print(val)
'''
#####################
## get commits for a user
a2c = {}
gA2C = {}

for user in input.keys():
	a2c[user] = []
	for author in input[user]:
		for commit in Author(author.encode('utf-8')).commit_shas:
			a2c[user].append(commit)

for author in gA.keys():
	gA2C[author] = []
	for commit in Author(author).commit_shas:
		gA2C[author].append(commit)

'''
for key, val in a2c.items():
	print(key),
	print(":"),
	print(val)
'''

#####################
## get blobs for a user
a2b = {}
for user in input.keys():
	a2b[user] = []
	for commit in a2c[user]:
		if Commit(commit).blob_shas_rel:
			for blob in Commit(commit).blob_shas_rel:
				a2b[user].append(blob)
	
'''
for key, val in a2b.items():
	print(key),
	print(":"),
	print(len(val))
'''
#####################
## get files for a user
u2f = {}
for user in input.keys():
	f2c = {}
	for commit in a2c[user]:
		for file in Commit(commit).files:
			if file not in f2c:
				f2c[file] = []
			f2c[file].append(commit)
	u2f[user] = f2c		
'''
for key, val in u2f.items():
	print(key),
	print(":"),
	print(val)
'''
#####################
## get commits for projects

p2c = {}
p2nc = {}
for user in input.keys():
	for proj in a2p[user]:
		if proj not in p2c.keys() or proj not in p2nc.keys():
			p2c[proj] = []
			p2nc[proj] = 0
		for commit in Project(proj).commit_shas:
			p2c[proj].append(commit)
			p2nc[proj] += 1
'''
for key, val in p2nc.items():
	print(key),
	print(":"),
	print(val)
'''

prof = db["profile"]
PS = db["projects"]
BS = db["blobs"]
AS = db["friends"]

for user in input.keys():
	result = {}
	A, Af, P, Pf, B, Bf = ([] for i in range(6))
	Ti = {}
	
	authors = u2a[user]
	commits = a2c[user]
	blobs = a2b[user]
	files = u2f[user]
	projects = a2p[user]
	if doPrj:
		clb = {}
		clb1 = {}

		for proj in projects:
			for author in sorted(authors[proj], key = lambda k: len(gA2C.get(k)), reverse = True):
				if author not in clb.keys():
					clb[author] = []
				clb[author].append(proj)
				if proj not in clb1.keys():
					clb1[proj] = []
				clb1[proj].append(author)
			nMyC = 0
			for commit in commits:
				if commit in p2c[proj]:
					nMyC += 1
			url = Project(proj).toURL()

			if len(P) < 30:
				P.append({'name': proj, 'nC': p2nc[proj], 'nMyC': nMyC, 'url': url})

			Pf.append({'name': proj, 'nC': p2nc[proj], 'nMyC': nMyC, 'url': url})
	
		result['projects'] = P
		topP = sorted(clb1.keys(), key = lambda k: len(clb1.get(k)), reverse = True)
		#print('{0:s} project with most collaborators {1:s} = {2:d}'.format(user, topP[0], len(clb1[topP[0]])))
		for author in sorted(clb.keys(), key = lambda k: len(gA2C.get(k)), reverse = True):
			pr = []
			ppp = clb[author]
			for p in ppp:
				nc = 0
				ccc = gA2C[author]
				for c in ccc:
					if p in p2nc.keys() and c in p2c[p]:
						nc += 1
				na = 0
				aaa = u2a[user]
				if len(aaa) < 2000:
					for au1 in aaa:
						if au1 in u2a[user][p]:
							na += 1
			pr.append({'nc': nc, 'name': p, 
						'nAuth': na})
			if len(A) < 30:
				A.append({'id': author, 'projects': pr})
			Af.append({'id': author, 'projects': pr})
			if len(Af) > 2000:
				continue
		result['friends'] = A
	
	if doFiles:
		F = {}
		for file in files:
			la = "other"
			if re.search("\.(js|iced|liticed|iced.md|coffee|litcoffee|coffee.md|ts|cs|ls|es6|es|jsx|sjs|co|eg|json|json.ls|json5)$",file):
				la = "js"
			elif re.search("\.(py|py3|pyx|pyo|pyw|pyc|whl)$",file):
				la = "py"
			elif re.search("(\.[Cch]|\.cpp|\.hh|\.cc|\.hpp|\.cxx)$",file):
				la = "c"
			elif re.search("(\.Rd|\.[Rr]|\.Rprofile|\.RData|\.Rhistory|\.Rproj|^NAMESPACE|^DESCRIPTION|\/NAMESPACE|\/DESCRIPTION)$",file):
				la = "r"
			elif re.search("\.(sh|shell|csh|zsh|bash)$",file):
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
			cs = u2f[user][file]
			if la not in F:
				F[la] = 0
			F[la] += len(cs) + 1

		result['files'] = F
		
	if doBlobs:
		c2ta = {}
		c2h = {}
		
		for commit in a2c[user]:
			if commit not in c2ta.keys():
				c2ta[commit] = ()
			c2ta[commit] = Commit_info(commit).time_author
			c2h[commit] = Commit_info(commit).head
		
		b2c = {}
		b2nc = {}
		b2na = {}
		b2depth = {}
		for blob in blobs:
			b2c[blob] = []
			#list of commit_shas for this blob is non-empty
			if Blob(blob).commit_shas:
				for commit in Blob(blob).commit_shas:
					b2c[blob].append(commit)
			#This blob is stored in one of the "large" tch files, and has too many commits
			#to store in b2c. We'll skip this blob if that's the case.
			else:
				continue
			bl, nc, csb = blob, len(b2c[blob]), b2c[blob]
			bas = {}
			for c in csb:
				if c in c2ta.keys():
					t, au = c2ta[c][0], c2ta[c][1]
					if t not in bas.keys():
						bas[t] = {}
					bas[t][au] = c
					if c2h[c]:
						depth = int(c2h[c][1], 16)
						if bl not in b2depth.keys() or b2depth[bl] < depth:
							b2depth[bl] = depth
			first = sorted(bas.keys())[0]
			aa = bas[first]
			first_auth = aa.keys()
			if first_auth[0] in input[user]:
				own = True
			else:
				own = False
			if own:
				b2na[bl] = {}
				for t in bas.keys():
					aa = bas[t]
					for au in aa:
						if au not in input[user]:
							co = bas[t][au]
							b2na[bl][au] = co
							if c2h[co]:
								depth = int(c2h[co][1], 16)
								if bl not in b2depth.keys() or b2depth[bl] < depth:
									b2depth[bl] = depth
			if bl in b2na.keys():
				b2nc[bl] = nc
		if b2nc and b2na:
			for b1, nc in sorted(b2nc.items(), key = lambda kv: kv[1], reverse=True):
				val = {}
				for au in b2na[b1]:
					c = b2na[b1][au]
					val[c] = au
				if len(B) < 20:
					B.append({'blob': b1, 'nc': b2nc[b1], 'depth': b2depth[b1], 'users': val})
				Bf.append({'blob': b1, 'nc': b2nc[b1], 'depth': b2depth[b1], 'users': val})
			#print("done Blobs")
			result['blobs'] = B

	if doPrj and doFiles and doBlobs:
		result['stats'] = { 'NFriends': len(authors)+1, 'NCommits': len(commits)+1, 'NBlobs': len(blobs)+1, 
							'NFiles': len(files)+1, 'NProjects': len(projects)+1}
	
	#objects = prof.find({'user'.encode('utf-8'): str(user).encode('utf-8')})
	objects = prof.find({'user': str(user)})
	if objects.count() >= 0:
		prof.update_one({'user': str(user)}, {"$set": {key: val for key,val in result.items()}})
	else:
		result['user'] = str(user)
		prof.insert_one({key: val for key, val in result.items()})
	
	if doPrj and sys.getsizeof(Pf) < 10000000:
		objects = PS.find({'user': str(user)})
		if objects.count() > 0:
			PS.update_one({'user': str(user)}, {"$set": {'projects': Pf}})
		else:
			PS.insert_one({'user': str(user), 'projects': Pf})

	if doBlobs and sys.getsizeof(Bf) < 10000000:
		objects = BS.find({'user': str(user)})
		if objects.count() > 0:
			BS.update_one({'user': str(user)}, {"$set": {'blobs': Bf}})
		else:
			BS.insert_one({'user': str(user), 'blobs': Bf})

	if doPrj and sys.getsizeof(Af) < 10000000:
		objects = AS.find({'user': str(user)})
		if objects.count() > 0:
			AS.update_one({'user': str(user)}, {"$set": {'friends': Af}})
		else:
			AS.insert_one({'user': str(user), 'friends': Af})
		
