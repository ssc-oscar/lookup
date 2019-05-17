import pymongo
from oscar import *

badProjects = {
  "bb_fusiontestaccount_fuse-2944": "32400A",
  "bb_fusiontestaccount_fuse1999v2": "34007A", 
  "octocat_Spoon-Knife": "forking tutorial, 41176A", 
  "cirosantilli_imagine-all-the-people": "Commit email scraper, 389993A",
  "marcelstoer_nodemcu-custom-build": "97994A",
  "jasperan_github-utils": "4394779C", 
  "avsm_ocaml-ci.logs": "4283368C"}

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
## get projects for a user
a2p = {}
for user in input.keys():
	a2p[user] = []
	for author_id in input[user]:
		projects = Author(author_id.encode('utf-8')).project_names
		a2p[user].append(projects)
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
	for project_tuple in a2p[user]:
		for proj in project_tuple:
			if proj in badProjects.keys() or proj in p2a.keys():
				continue
			a_names = Project(proj).author_names
			p2a[proj] = []
			for author in a_names:
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

'''
for author in gA.keys():
	gA2C[author] = []
	for commit in Author(author).commits:
		gA2C[author].append(commit)
'''
## ^^^ takes a LONG time, there are 5,174 authors in gA dictionary

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
	print(val)
'''
#####################
## get files for a user


			
