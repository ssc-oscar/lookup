# Tutorial basics for Hackathon

## List of relevant directories
### da0 Server
<relationship>.{0-31}.tch files in `/data/basemaps/`:
	(.s) signifies that there are either .s or .gz versions of these files in gz/ subfolder, 
	which can be opened with Python gzip module or Unix zcat
	Key for identifying letters:
		a  - Author
		b  - Blob
		c  - Commit
		cc - Child Commit
		f  - File
		h  - Head Commit
		p  - Project
		pc - Parent Commit
		ta - Time_Author
		trp - Torvald Path
	List of relationships:
	* a2c (.s)	* a2f		* a2p (.s)		*a2trp0 (.s)
	* b2c (.s)	* b2f (.s)
	* c2b (.s)	* c2cc		* c2f (.s)		
	* c2h		* c2pc		* c2p (.s)		* c2ta (.s)
	* f2b (.s)	* f2c (.s)		
	* p2a (.s)	* p2c (.s)
------
$LANGthruMaps in `/data/play/`:
		These thruMaps files contain mappings of repositories with modules that were utilized at a given UNIX timestamp under a specific commit.
		Format: `commit;repo_name;timestamp;author;blob;module1;module2;...`
		Each thruMaps file has a different language ($LANG) that contains modules relevant to that language.
------
### da3 Server
.tch files in `/fast/`:
		da3 contains the same files located on da0, except for b2f, c2cc, f2b, and f2c.
		This folder can be used for faster reading, hence the directory name.
		The .s/.gz files are on da0 only.

## OSCAR functions from oscar.py
These are corresponding functions in oscar.py that open the .tch files listed above for a given entity:

	Note: "/<function_name>" after a function name denotes the version of that function that 
		  returns a Generator object  

1. `Author('...')`  - initialized with a combination of name and email
	* `.commit_shas/commits`
	* `.project_names`
	* `.torvald` - returns the torvald path of an Author, i.e, who did this Author work
				 with that also worked with Linus Torvald
2. `Blob('...')` -  initialized with SHA of blob
	* `.commit_shas/commits` - commits removing this blob are not included
3. `Commit('...')` - initialized with SHA of commit
	* `.blob_shas/blobs`
	* `.child_shas/children`
	* `.changed_file_names/files_changed`
	* `.parent_shas/parents`
	* `.project_names/projects`
4. `Commit_info('...')` - initialized like Commit()
	* `.head`
	* `.time_author`
5. `File('...')` - initialized with a path, starting from a commit root tree
	* `.commit_shas/commits`
6. `Project('...')` - initialized with project name/URI
	* `.author_names`
	* `.commit_shas/commits`

The non-Generator version of these functions will return a tuple of items which can 
then be iterated:
```
for commit in Author(author_name).commit_shas:
	print(commit)
```
------
## Examples of doing certain tasks
* Get a list of commits and repositories that imported Tensorflow for .py files:
	On da0: `UNIX> zcat /data/play/PYthruMaps/c2bPtaPkgOPY.0.gz | grep tensorflow`
	Output: 
	```
	0000331084e1a567dbbaae4cc12935b610cd341a;abdella-mohamed_BreastCancer;1553266304;abdella <abdella.mohamed-idris-mohamed@de.sii.group>;0dd695391117e784d968c111f010cff802c0e6d1;sns;keras.models;np;random;tensorflow;os;pd;sklearn.metrics;plt;keras.layers;yaml
	000034db68f89d3d2061b763deb7f9e5f81fef27;lucaskjaero_chinese-character-recognizer;1497547797;Lucas Kjaero <lucas@lucaskjaero.com>;0629a6caa45ded5f4a2774ff7a72738460b399d4;tensorflow;preprocessing;sklearn
	000045f6a3601be885b0b028011440dd5a5b89f2;yjernite_DeepCRF;1451682395;yacine <yacine.jernite@nyu.edu>;4aac89ae85b261dba185d5ee35d12f6939fc2e44;nn_defs;utils;tensorflow
	000069240776f2b94acb9420e042f5043ec869d0;tickleliu_tf_learn;1530460653;tickleliu <tickleliu@163.com>;493f0fc310765d62b03390ddd4a7a8be96c7d48c;np;tf;tensorflow
	```
* Get a list of commits made by a specific author:
	On da0: `UNIX> zcat /data/basemaps/gz/a2cFullP0.s | grep "Albert Krawczyk" <pro-logic@optusnet.com.au>` 
	Output: 
	```
	"Albert Krawczyk" <pro-logic@optusnet.com.au>;17abdbdc90195016442a6a8dd8e38dea825292ae
	"Albert Krawczyk" <pro-logic@optusnet.com.au>;9cdc918bfba1010de15d0c968af8ee37c9c300ff
	"Albert Krawczyk" <pro-logic@optusnet.com.au>;d9fc680a69198300d34bc7e31bbafe36e7185c76
	```
	
## Implementing applications
