import urllib, json, csv, math, re, requests
from collections import Counter
from itertools import izip
from operator import itemgetter, attrgetter, methodcaller
import numpy as np
from scipy import stats
from array import array
import MySQLdb
# from metadataToDataBase import extractData

metadataSimilarities = {}


# def extractSimilar(pid):
# 	result = []
# 	r = requests.get('http://vistatv.eculture.labs.vu.nl/get_similar_programme?pid=' + pid)
# 	json_data = r.json()
# 
# 	return json_data
# 
# def writeSim(pid1, pid2, cosineBoth,cosineMeta,cosineLD):
# 	conn = MySQLdb.connect(host= "host",
#                   user="username",
#                   passwd="password",
#                   db="databse")
# 
# 	x = conn.cursor()
# 
# 	x.execute("""INSERT INTO `Both similarity` (pid1,pid2,sim_value) VALUES (%s,%s,%s)""", (pid1,pid2,cosineBoth))
# 	x.execute("""INSERT INTO `LOD similarity` (pid1,pid2,sim_value) VALUES (%s,%s,%s)""", (pid1,pid2,cosineLD))
# 	x.execute("""INSERT INTO `Metadata similarity` (pid1,pid2,sim_value) VALUES (%s,%s,%s)""", (pid1,pid2,cosineMeta))
# 	conn.commit()
# 
# 
def calculateCosineMetadataFromFile(pid1, pid2):
	try:
		return metadataSimilarities[pid1][pid2]
	except:
		return metadataSimilarities[pid2][pid1]
# 		
# 	
# 
# def calculateCosineMetadata(pid1, pid2):
# 	#print pid1, pid2
# 	#print "a", a
# 	#print "b", b
# 
# 	a = []
# 	b = []
# 	position = 3
# 	while(position < 9):
# 		if(len(pid1[position]) > 0 and len(pid2[position])> 0):
# 			for i in pid1[position]:
# 				a.append(i)
# 			for i in pid2[position]:
# 				b.append(i)
# 		position += 1
# 
# 
# 	# reference: http://stackoverflow.com/questions/28819272/python-how-to-calculate-the-cosine-similarity-of-two-lists
# 	# count word occurrences
# 	a_vals = Counter(a)
# 	b_vals = Counter(b)
# 	#print a_vals
# 	#print b_vals
# 
# 	# convert to word-vectors
# 	word = list(set(a_vals) | set(b_vals))
# 	a_vect = [a_vals.get(words, 0) for words in word]     
# 	b_vect = [b_vals.get(words, 0) for words in word]    
# 
# 	# find cosine
# 	len_a  = math.sqrt(sum(av*av for av in a_vect))      
# 	len_b  = math.sqrt(sum(bv*bv for bv in b_vect))  
# 	#print len_a
# 	#print len_b     
# 	dot    = sum(av*bv for av,bv in zip(a_vect, b_vect))   
# 	#print dot
# 	if dot == 0 or (len_a * len_b) == 0:
# 		cosine = 0
# 		#print dot, len_a * len_b
# 	else:
# 		cosine = dot / (len_a * len_b)
# 	#print cosine                          
# 	return cosine
# 
# def calculateCosineLD(a, b):
# 	upper = 0
# 	lower_b = 0
# 	lower_a = 0
# 
# 	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_properties_frequency_per_position?pid=' + a + '&position=1')
# 	json_data_a = r.json()
# 	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_properties_frequency_per_position?pid=' + b + '&position=1')
# 	json_data_b = r.json()
# 
# 	for j in json_data_a:
# 		for i in json_data_b:
# 			if j['value'] == i['value']:
# 				multiply = (i['frequency'] * j['frequency'])
# 				upper += multiply
# 
# 	for i in json_data_a:
# 		lower_a += (i['frequency']*i['frequency'])
# 
# 
# 	for i in json_data_b:
# 		lower_b += (i['frequency']*i['frequency'])
# 
# 
# 	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_types_frequency_per_position?pid=' + a + '&position=1')
# 	json_data_a = r.json()
# 	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_types_frequency_per_position?pid=' + b + '&position=1')
# 	json_data_b = r.json()
# 	for j in json_data_a:
# 		for i in json_data_b:
# 			if j['value'] == i['value']:
# 				multiply = (i['frequency'] * j['frequency'])
# 				upper += multiply
# 
# 
# 	for i in json_data_a:
# 		lower_a += (i['frequency']*i['frequency'])
# 
# 	for i in json_data_b:
# 		lower_b += (i['frequency']*i['frequency'])
# 
# 	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_properties_frequency_per_position?pid=' + a + '&position=2')
# 	json_data_a = r.json()
# 	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_properties_frequency_per_position?pid=' + b + '&position=2')
# 	json_data_b = r.json()
# 
# 	for j in json_data_a:
# 		for i in json_data_b:
# 			if j['value'] == i['value']:
# 				multiply = (i['frequency'] * j['frequency'])
# 				upper += multiply
# 
# 	for i in json_data_a:
# 		lower_a += (i['frequency']*i['frequency'])
# 
# 
# 	for i in json_data_b:
# 		lower_b += (i['frequency']*i['frequency'])
# 
# 
# 	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_types_frequency_per_position?pid=' + a + '&position=2')
# 	json_data_a = r.json()
# 	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_types_frequency_per_position?pid=' + b + '&position=2')
# 	json_data_b = r.json()
# 	for j in json_data_a:
# 		for i in json_data_b:
# 			if j['value'] == i['value']:
# 				multiply = (i['frequency'] * j['frequency'])
# 				upper += multiply
# 
# 
# 	for i in json_data_a:
# 		lower_a += (i['frequency']*i['frequency'])
# 
# 	for i in json_data_b:
# 		lower_b += (i['frequency']*i['frequency'])
# 
# 	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_properties_frequency_per_position?pid=' + a + '&position=3')
# 	json_data_a = r.json()
# 	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_properties_frequency_per_position?pid=' + b + '&position=3')
# 	json_data_b = r.json()
# 
# 	for j in json_data_a:
# 		for i in json_data_b:
# 			if j['value'] == i['value']:
# 				multiply = (i['frequency'] * j['frequency'])
# 				upper += multiply
# 
# 	for i in json_data_a:
# 		lower_a += (i['frequency']*i['frequency'])
# 
# 
# 	for i in json_data_b:
# 		lower_b += (i['frequency']*i['frequency'])
# 
# 
# 	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_types_frequency_per_position?pid=' + a + '&position=3')
# 	json_data_a = r.json()
# 	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_types_frequency_per_position?pid=' + b + '&position=3')
# 	json_data_b = r.json()
# 	for j in json_data_a:
# 		for i in json_data_b:
# 			if j['value'] == i['value']:
# 				multiply = (i['frequency'] * j['frequency'])
# 				upper += multiply
# 
# 
# 	for i in json_data_a:
# 		lower_a += (i['frequency']*i['frequency'])
# 
# 	for i in json_data_b:
# 		lower_b += (i['frequency']*i['frequency'])
# 	
# 	lower = math.sqrt(lower_a) * math.sqrt(lower_b)
# 	if not upper == 0 or not lower == 0.0:
# 		cosine = upper/lower 
# 	else:
# 		cosine = 0  
# 	#print a, b, cosine                
# 	return cosine

pids = []

with open('../Data/pids.csv', 'rU') as g:
	readers = csv.reader(g, delimiter =',')
	for row in readers:
		pids.append(row[0])
		#print row


with open('metadataSimilarities.csv', 'rU') as g:
	readers = csv.reader(g, delimiter =',')
	for row in readers:
		if row[0] not in metadataSimilarities.keys():
			metadataSimilarities[row[0]]={}
		metadataSimilarities[row[0]][row[1]] = row[2]


# pid_one = []
# pid_two = []
# 
# for i in pids:
# 	try:
# 		addInfo = extractData(i)
# 		addInfo.insert(0,i)
# 		pid_one.append(addInfo)
# 		pid_two.append(addInfo)
# 	except Exception:
# 		print i
# 
# print 'total after selection', len(pid_one)
# 
# #print pid_one
# #print pid_two
# written = 0
# for pid1 in pid_one:
# 	check = extractSimilar(pid1[0])
# 	#print "1", pid1[0]
# 	for pid2 in pid_two:
# 		#print "2", pid2[0]
# 		if not pid1[0] == pid2[0]:
# 			
# # 			cosineMeta = calculateCosineMetadata(pid1,pid2)
# 			cosineMeta = calculateCosineMetadataFromFile(pid1,pid2)
# 			if pid2[0] in check:
# 				#print pid1[0], pid2[0]
# 				cosineLD = calculateCosineLD(pid1[0],pid2[0])
# 				#print cosine
# 			else:
# 				cosineLD = 0
# 			cosineBoth = (cosineMeta+cosineLD)/2
# 			writeSim(pid1[0], pid2[0], cosineBoth,cosineMeta,cosineLD )
# 	pid_two.remove(pid1)
