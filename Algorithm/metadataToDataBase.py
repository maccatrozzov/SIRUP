import urllib, json, csv, math, re
from collections import Counter
from itertools import izip
from operator import itemgetter, attrgetter, methodcaller
import numpy as np
from scipy import stats
from array import array
import MySQLdb
import itertools

def writeSim(pid1, pid2, cosine):
	conn = MySQLdb.connect(host= "localhost",
                  user="root",
                  passwd="",
                  db="SIRUP")

	x = conn.cursor()

	x.execute("""INSERT INTO `Metadata similarity` (pid1,pid2,sim_value) VALUES (%s,%s,%s)""", (pid1,pid2,cosine))
	conn.commit()

def extractData(pid):
	result = []
	conn = MySQLdb.connect(host= "localhost",
                  user="root",
                  passwd="",
                  db="vista_tv_bbc")

	cursor = conn.cursor()
# 	url = "http://www.bbc.co.uk/programmes/"+pid+".json" #make URL with pid in it

	# response = urllib.urlopen(url); #open the URL
# 	dataPROGRAM = json.loads(response.read()) #extract all data in the JSON file and put in variable
# 	performers = []
# 	contributors = []
# 	try:
# 		canonicalPROGRAM = dataPROGRAM['programme']['versions'][0]['pid'] #canonical, will be used for extra information
# 		url = "http://www.bbc.co.uk/programmes/"+canonicalPROGRAM+".json" #make URL of canonical pid
# 		response = urllib.urlopen(url); #open canonical URL
# 
# 		dataCANONICAL = json.loads(response.read()) #save canonical data in variable
# 
# 		try:
# 			performersInfo = dataCANONICAL['version']['segment_events']
# 			for p in performersInfo:
# 				performers.append(p['segment']['artist'].encode("utf-8"))
# 		except Exception:
# 			print "performers"
# 		contributorsInfo = dataCANONICAL['version']['contributors'] # no distinction between writer/author etc.
# 		
# 		for c in contributorsInfo:
# 			contributors.append(c['name'].encode("utf-8"))
# 	except Exception:
# 		pass
	cursor.execute("select cat_id as cat from programme_categories where pid = %s", (pid))
	information = [item[0] for item in cursor.fetchall()]
	
	cursor.execute("select credit_id as credit from programme_credits where pid = %s", (pid))
	contributors = [item[0] for item in cursor.fetchall()]
	
	cursor.execute("select title as title from programme_info where pid = %s", (pid))
	title = [item[0] for item in cursor.fetchall()]
	
	cursor.execute("select episode_title as title from programme_info where pid = %s", (pid))
	subtitle = [item[0] for item in cursor.fetchall()]
	
	cursor.execute("select annotation_value as annotation from programme_annotations where pid = %s", (pid))
	annotations = [item[0] for item in cursor.fetchall()]
	
	conn.commit()
	
	# title = dataPROGRAM['programme']['display_title']['title'] #extract title
# 	title = title.encode("utf-8")
# 	#result.append(title)
# 	subtitle = dataPROGRAM['programme']['title'] #extract subtitle
# 	subtitle = subtitle.encode("utf-8")
# 	#result.append(subtitle)
# 	
# 	#duration = dataPROGRAM['programme']['versions'][0]['duration']
# 
# 	#initialize variables for storage
# 	# lists used in case multiple options are available
# 	information = dataPROGRAM['programme']['categories']
# 	genre = []
# 	format = []
# 	subject = []
# 	for i in information:
# 		if i['type'] == 'genre':
# 			if not i['title'].encode("utf-8") in genre: #only store each genre one time']
# 				genre.append(i['title'].encode("utf-8"))
# 		if i['type'] == 'format':
# 			if not i['title'] in format: #only store each format one time
# 				format.append(i['title'].encode("utf-8"))
# 		if i['type'] == 'subject':
# 			if not i['title'] in subject: #only store each subject one time
# 				subject.append(i['title'].encode("utf-8"))

# 
# 	#### find programmeType. In try statement cause not all programme have a type, which will cause an error
# 	typeProgram = []
# 	try:
# 		typeProgram.append(dataPROGRAM['programme']['parent']['programme']['type'].encode("utf-8"))
# 	except Exception:
# 		pass
# 
# 	try:
# 		service = dataPROGRAM['programme']['ownership']['service']['title']
# 	except Exception:
# 		service = dataPROGRAM['programme']['parent']['programme']['ownership']['service']['title']
# 
# 	'''synopsisShort = dataPROGRAM['programme']['short_synopsis']
# 				synopsisMedium = dataPROGRAM['programme']['medium_synopsis']
# 				
# 				if len(synopsisMedium)>0:
# 					synopsis = synopsisMedium
# 				else:
# 					synopsis = synopsisShort'''
# 
	flat_list = list(itertools.chain(*[title, subtitle, information, annotations, contributors]))
 	return flat_list


def calculateCosine(pid1, pid2):
	#print pid1, pid2
	#print "a", a
	#print "b", b

	a = pid1
	b = pid2
	# position = 3
# 	while(position < 9):
# 		if(len(pid1[position]) > 0 and len(pid2[position])> 0):
# 			for i in pid1[position]:
# 				a.append(i)
# 			for i in pid2[position]:
# 				b.append(i)
# 		position += 1


	# reference: http://stackoverflow.com/questions/28819272/python-how-to-calculate-the-cosine-similarity-of-two-lists
	# count word occurrences
	a_vals = Counter(a)
	b_vals = Counter(b)
	#print a_vals
	#print b_vals

	# convert to word-vectors
	word = list(set(a_vals) | set(b_vals))
	a_vect = [a_vals.get(words, 0) for words in word]     
	b_vect = [b_vals.get(words, 0) for words in word]    

	# find cosine
	len_a  = math.sqrt(sum(av*av for av in a_vect))      
	len_b  = math.sqrt(sum(bv*bv for bv in b_vect))  
	#print len_a
	#print len_b     
	dot    = sum(av*bv for av,bv in zip(a_vect, b_vect))   
	#print dot
	if dot == 0 or (len_a * len_b) == 0:
		cosine = 0
		#print dot, len_a * len_b
	else:
		cosine = dot / (len_a * len_b)
	#print cosine                          
	return cosine

pids = []

doubles = 0

with open('../Data/pids.csv', 'rU') as g:
	readers = csv.reader(g, delimiter =',')
	for row in readers:
		pids.append(row[0])
		#print row

pid_one = []
pid_two = []

for i in pids:
	try:
		addInfo = extractData(i)
		addInfo.insert(0,i)
		pid_one.append(addInfo)
		pid_two.append(addInfo)
	except Exception:
		print i

	
print 'total after selection', len(pid_one)

#print pid_one
#print pid_two
written = 0
for pid1 in pid_one:
	#print "1", pid1[0]
	for pid2 in pid_two:
		#print "2", pid2[0]
		if not pid1[0] == pid2[0]:
			#print "hello"
			#print pid1[0], pid2[0]
			cosine = calculateCosine(pid1,pid2)
 			writeSim(pid1[0], pid2[0], cosine)
	
	pid_two.remove(pid1)


# for every pid1
	# for very other pid2
		# calculate similarity value
			# write similarity value to database


	# take away pid1 from list


#def calculate sim (pid1, pid2)
	# eextract data BBC
	# take into account the information that is avaiable for both
	# calculate similarity between to
