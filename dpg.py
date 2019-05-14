import pymongo
from oscar import *

client = pymongo.MongoClient("mongodb://da1.eecs.utk.edu/")

db = client["WoC"]
col = db["users"]
users = col.find({})

## get author ids for each user
user2authors = {}

for user in users:
	user2authors[user['_id']] = []
	for selectId in user['selectedIds']:
		if isinstance(selectId, basestring):
			user2authors[user['_id']].append(selectId)
		elif isinstance(selectId, dict):
			user2authors[user['_id']].append(selectId['id'])
'''
for key, val in user2authors.items():
	print(key),
	print(":"),
	print(val)
'''
## get projects for a user
a2p = {}
for user in user2authors.keys():
	for author_id in user2authors[user]:
		projects = Author(author_id.encode('utf-8')).project_names
		a2p[author_id] = projects
'''
for key, val in a2p.items():
	print(key),
	print(":"),
	print(val)
'''
