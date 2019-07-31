# Tutorial basics for Hackathon

## List of relevant directories
### da0 Server
#### <relationship>.{0-31}.tch files in `/data/basemaps/`:  
(.s) signifies that there are either .s or .gz versions of these files in gz/ subfolder, which can be opened with Python gzip module or Unix zcat.  
da0 is the only server with these .s/.gz files  
Keys for identifying letters:   

* a = Author
* b = Blob
* c = Commit
* cc = Child Commit
* f = File
* h = Head Commit
* p = Project
* pc = Parent Commit
* ta = Time Author
* trp = Torvald Path

List of relationships:
```
* a2c (.s)		* a2f			* a2p (.s)			* a2trp0 (.s)
* b2c (.s)		* b2f (.s)
* c2b (.s)		* c2cc			* c2f (.s)		
* c2h			* c2pc			* c2p (.s)			* c2ta (.s)
* f2b (.s)		* f2c (.s)		
* p2a (.s)		* p2c (.s)
```	
------
#### `/data/play/$LANGthruMaps/` on da0:  
These thruMaps directories contain mappings of repositories with modules that were utilized at a given UNIX timestamp under a specific commit. The mappings are in c2bPtaPkgO{$LANG}.{0-31}.gz files.   
Format: `commit;repo_name;timestamp;author;blob;module1;module2;...`  
Each thruMaps directory has a different language ($LANG) that contains modules relevant to that language.
------
### da3 Server
#### .tch files in `/fast/`:  
da3 contains the same files located on da0, except for b2f, c2cc, f2b, and f2c.
This folder can be used for faster reading, hence the directory name.  
In the context of oscar.py, the dictionary values listed in the PATHS dictionary can be changed from `/da0_data/basemaps/...` to `/fast/...` when referencing oscar.py in another program.  
------
## OSCAR functions from oscar.py
Note: "/<function_name>" after a function name denotes the version of that function that returns a Generator object  

These are corresponding functions in oscar.py that open the .tch files listed above for a given entity:

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

The non-Generator version of these functions will return a tuple of items which can then be iterated:
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
00034db68f89d3d2061b763deb7f9e5f81fef27;lucaskjaero_chinese-character-recognizer;1497547797;Lucas Kjaero <lucas@lucaskjaero.com>;0629a6caa45ded5f4a2774ff7a72738460b399d4;tensorflow;preprocessing;sklearn
000045f6a3601be885b0b028011440dd5a5b89f2;yjernite_DeepCRF;1451682395;yacine <yacine.jernite@nyu.edu>;4aac89ae85b261dba185d5ee35d12f6939fc2e44;nn_defs;utils;tensorflow
000069240776f2b94acb9420e042f5043ec869d0;tickleliu_tf_learn;1530460653;tickleliu <tickleliu@163.com>;493f0fc310765d62b03390ddd4a7a8be96c7d48c;np;tf;tensorflow
.....
```
* Get a list of commits made by a specific author:  
	On da0: `UNIX> zcat /data/basemaps/gz/a2cFullP0.s | grep "Albert Krawczyk" <pro-logic@optusnet.com.au>`  
	Output:  
```
"Albert Krawczyk" <pro-logic@optusnet.com.au>;17abdbdc90195016442a6a8dd8e38dea825292ae
"Albert Krawczyk" <pro-logic@optusnet.com.au>;9cdc918bfba1010de15d0c968af8ee37c9c300ff
"Albert Krawczyk" <pro-logic@optusnet.com.au>;d9fc680a69198300d34bc7e31bbafe36e7185c76
```
* Do the same thing above using oscar.py:  
```
UNIX> python
>>> from oscar import Author
>>> Author('"Albert Krawczyk" <pro-logic@optusnet.com.au>').commit_shas
('17abdbdc90195016442a6a8dd8e38dea825292ae', '9cdc918bfba1010de15d0c968af8ee37c9c300ff', 'd9fc680a69198300d34bc7e31bbafe36e7185c76')
```
* Get the URL of a projects repository using the oscar.py `Project(...).toURL()` function:  
```
UNIX> python
>>> from oscar import Project
>>> Project('notcake_gcad').toURL()
'https://github.com/notcake/gcad'
```
-------	
## Examples of implementing applications  
### Finding 1st-time imports for AI modules  
Given the data available, this is a fairly simple task. Making an application to detect the first time that a repo adopted an AI module would give you a better idea as to when it was first used, and also when it started to gain popularity.  

A good example of this lies in [popmods.py](https://github.com/ssc-oscar/aiframeworks/blob/master/popmods.py). In this application, we can read all 32 c2bPtaPkgO$LANG.{0-31}.gz files of a given language and look for a given module with the earliest import times. The program then creates a <module_name>.first file, with each line formatted as `repo_name;UNIX_timestamp`.  

Usage: `UNIX> python popmods.py language_file_extension module_name`  

Before anything else (and this can be applied to many other programs), you want to know what your input looks like ahead of time and know how you are going to parse it. Since each line of the file has this format:  
`commit;repo_name;timestamp;author;blob;module1;module2;...`  
We can use the `string.split()` method to turn this string into a list of words, split by a semicolon (;).  
By turning this line into a list, and giving it a variable name, `entry = ['commit', 'repo_name', 'timestamp', ...]`, we can then grab the pieces of information we need with `repo, time = entry[1], entry[2]`. 

An important idea to keep in mind is that we only want to count unique timestamps once. This is because we want to account for repositories that forked off of another repository with the exact timestamp of imports. An easy way to do this would be to keep a running list of the times we have come across, and if we have already seen that timestamp before, we will simply skip that line in the file:  
```
...
if time in times:
	continue
else:
	times.append(time)
...
```
We also want to find the earliest timestamp for a repository importing a given module. Again, this is fairly simple:  
```
...
if repo not in dict.keys() or time < dict[repo]:
	for word in entry[5:]:
		if module in word:
			dict[repo] = time
			break
...
```
#### Implementing the application
Now that we have the .first files put together, we can take this one step further and graph a module`s first-time usage over time on a line graph, or even compare multiple modules to see how they stack up against each other. [modtrends.py](https://github.com/ssc-oscar/aiframeworks/blob/master/modtrends.py) accomplishes this by:  
* reading 1 or more .first files  
* converting each timestamp for each repository into a datetime date 
* "rounding" those dates by year and month  
* putting those dates in a dictionary with `dict["year-month"] += 1`
* graphing the dates and frequencies using matplotlib.  
If you want to compare first-time usage over time for Tensorflow and Keras for the .ipynb language .first files you created, run: `UNIX> python3.6 modtrends.py tensorflow.first keras.first`  
The final graph should look something like this:  
![Tensorflow vs Keras](https://github.com/ssc-oscar/aiframeworks/blob/master/charts/ipynb_charts/Tensorflow-vs-Keras.png)
-------
### Detecting percentage language use and changes over time  
An application to calculate this would be useful for seeing how different authors changed languages over a range of years, based on the commits they have made to different files.  
In order to accomplish this task, we will modify an existing program from the swsc/lookup repo (a2fBinSorted.perl) and create a new program that will get language counts per year per author.  



-------
## Useful Python imports for applications

