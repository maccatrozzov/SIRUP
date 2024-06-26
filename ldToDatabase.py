import urllib, json, csv, math, re, requests
from collections import Counter
from itertools import izip
from operator import itemgetter, attrgetter, methodcaller
import numpy as np
from scipy import stats
from array import array
import MySQLdb
from metadataToDataBase import extractData

def writeSim(pid1, pid2, cosine):
	conn = MySQLdb.connect(host= "host",
                  user="username",
                  passwd="password",
                  db="database")

	x = conn.cursor()

	x.execute("""INSERT INTO `LOD similarity` (pid1,pid2,sim_value) VALUES (%s,%s,%s)""", (pid1,pid2,cosine))
	conn.commit()

def extractSimilar(pid):
	r = requests.get('http://vistatv.eculture.labs.vu.nl/get_similar_programme?pid=' + pid)
	return r.json()


def calculateCosine(a, b):
	upper = 0
	lower_b = 0
	lower_a = 0

	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_properties_frequency_per_position?pid=' + a + '&position=1')
	json_data_a = r.json()
	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_properties_frequency_per_position?pid=' + b + '&position=1')
	json_data_b = r.json()

	for j in json_data_a:
		for i in json_data_b:
			if j['value'] == i['value']:
				multiply = (i['frequency'] * j['frequency'])
				upper += multiply

	for i in json_data_a:
		lower_a += (i['frequency']*i['frequency'])


	for i in json_data_b:
		lower_b += (i['frequency']*i['frequency'])


	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_types_frequency_per_position?pid=' + a + '&position=1')
	json_data_a = r.json()
	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_types_frequency_per_position?pid=' + b + '&position=1')
	json_data_b = r.json()
	for j in json_data_a:
		for i in json_data_b:
			if j['value'] == i['value']:
				multiply = (i['frequency'] * j['frequency'])
				upper += multiply


	for i in json_data_a:
		lower_a += (i['frequency']*i['frequency'])

	for i in json_data_b:
		lower_b += (i['frequency']*i['frequency'])

	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_properties_frequency_per_position?pid=' + a + '&position=2')
	json_data_a = r.json()
	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_properties_frequency_per_position?pid=' + b + '&position=2')
	json_data_b = r.json()

	for j in json_data_a:
		for i in json_data_b:
			if j['value'] == i['value']:
				multiply = (i['frequency'] * j['frequency'])
				upper += multiply

	for i in json_data_a:
		lower_a += (i['frequency']*i['frequency'])


	for i in json_data_b:
		lower_b += (i['frequency']*i['frequency'])


	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_types_frequency_per_position?pid=' + a + '&position=2')
	json_data_a = r.json()
	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_types_frequency_per_position?pid=' + b + '&position=2')
	json_data_b = r.json()
	for j in json_data_a:
		for i in json_data_b:
			if j['value'] == i['value']:
				multiply = (i['frequency'] * j['frequency'])
				upper += multiply


	for i in json_data_a:
		lower_a += (i['frequency']*i['frequency'])

	for i in json_data_b:
		lower_b += (i['frequency']*i['frequency'])

	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_properties_frequency_per_position?pid=' + a + '&position=3')
	json_data_a = r.json()
	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_properties_frequency_per_position?pid=' + b + '&position=3')
	json_data_b = r.json()

	for j in json_data_a:
		for i in json_data_b:
			if j['value'] == i['value']:
				multiply = (i['frequency'] * j['frequency'])
				upper += multiply

	for i in json_data_a:
		lower_a += (i['frequency']*i['frequency'])


	for i in json_data_b:
		lower_b += (i['frequency']*i['frequency'])


	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_types_frequency_per_position?pid=' + a + '&position=3')
	json_data_a = r.json()
	r = requests.get('http://vistatv.eculture.labs.vu.nl/local_types_frequency_per_position?pid=' + b + '&position=3')
	json_data_b = r.json()
	for j in json_data_a:
		for i in json_data_b:
			if j['value'] == i['value']:
				multiply = (i['frequency'] * j['frequency'])
				upper += multiply


	for i in json_data_a:
		lower_a += (i['frequency']*i['frequency'])

	for i in json_data_b:
		lower_b += (i['frequency']*i['frequency'])
	
	lower = math.sqrt(lower_a) * math.sqrt(lower_b)
	if not upper == 0 or not lower == 0.0:
		cosine = upper/lower 
	else:
		cosine = 0  
	#print a, b, cosine                
	return cosine

#####################################################################################

pids = []

with open('../Data/pids.csv', 'rU') as g:
	readers = csv.reader(g, delimiter =',')
	for row in readers:
		pids.append(row[0])

pid_one = []
pid_two = []

for i in pids:
	# title, subtitle, genre, format, subject, typeProgram, performers, contributors, service = extractData(i)
# 
# 	addInfo = [i, title, subtitle, genre, format, subject, typeProgram, performers, contributors]
	pid_one.append(i)
	pid_two.append(i)
print len(pid_one)

for pid1 in pid_one:
	check = extractSimilar(pid1[0])
	for pid2 in pid_two:
		if not pid1[0] == pid2[0]:
			if pid2[0] in check:
				#print pid1[0], pid2[0]
				cosine = calculateCosine(pid1[0],pid2[0])
				#print cosine
			else:
				cosine = 0
			writeSim(pid1[0],pid2[0],cosine)
	pid_two.remove(pid1)
