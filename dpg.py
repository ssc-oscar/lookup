import pymongo
'''
from oscar import Author
'''

client = pymongo.MongoClient("mongodb://da1.eecs.utk.edu/")

db = client["WoC"]
col = db["authors"]
cursor = col.find({})

for author in cursor:
	print(author['id'])



