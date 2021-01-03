#!/usr/bin/env -S PATH="${PATH}:/usr/local/bin" PYTHONIOENCODING=UTF-8 LC_ALL=en_US.UTF-8 python
# -*- coding: utf-8 -*-

then = "20201229160152"

import re, shutil, sys
import os.path, time
from datetime import datetime as dt
import json
from subprocess import Popen, PIPE
import numpy as np
from datetime import datetime as dt

file = os.path.basename(__file__)
__location__ = os.path.realpath(
	os.path.join(os.getcwd(), os.path.dirname(__file__)))

now = dt.today().strftime("%Y%m%d%H%M%S")

time_diff = int((dt.strptime(now, "%Y%m%d%H%M%S") - dt.strptime(then, "%Y%m%d%H%M%S")).total_seconds())
time_diff = str(time_diff)

get_bibs_all = Popen(['osascript', __location__ + '/bookends-generate_bib.scpt', "all", ""], stdin=PIPE, stdout=PIPE, stderr=PIPE, universal_newlines=True)
get_bibs_mod = Popen(['osascript', __location__ + '/bookends-generate_bib.scpt', "mod", time_diff], stdin=PIPE, stdout=PIPE, stderr=PIPE, universal_newlines=True)

bibs_all, bibs_all_err = get_bibs_all.communicate()
bibs_mod, bibs_mod_err = get_bibs_mod.communicate()

bibpath = __location__ + '/Library.bib'
jsonpath = __location__ + '/Library.json'
if not os.path.exists(bibpath):
	open(bibpath, 'w').close()
	mybib = ''
else:
	f = open(bibpath, "r")
	mybib = f.read()
	f.close()
	shutil.copy(bibpath, os.path.join(__location__, "Library_backup.bib"))
	
if not os.path.exists(jsonpath):
	open(jsonpath, 'w').close()
	myjson = '[]'
else:
	g = open(jsonpath, "r")
	myjson = g.read()
	g.close()
	shutil.copy(jsonpath, os.path.join(__location__, "Library_backup.json"))

data = json.loads(myjson)
citekeys = map(lambda datum: datum['id'], data)
not_in_bibfile = np.setdiff1d(bibs_all.rstrip("\n").split(", "),list(citekeys))
new_bibs = list(filter(None, not_in_bibfile))
changed_in_bibfile = np.setdiff1d(bibs_mod.rstrip("\n").split(","),new_bibs)
mod_bibs = list(filter(None, changed_in_bibfile))
# removed_from_bibfile = np.setdiff1d(list(citekeys),bibs_all.rstrip("/n").split(", "))

def get_bib(citekey):
	get_bib_record = Popen(['osascript', __location__ + '/bookends-generate_bib.scpt', "get_bib", citekey], stdin=PIPE, stdout=PIPE, stderr=PIPE, universal_newlines=True)
	formatted_bib, formatted_bib_err = get_bib_record.communicate()
	return formatted_bib

print()
print('Getting new bibliography records...')
print()
len_new_bibs = len(new_bibs)
processed_num = 1
for citekey in new_bibs:
	bib_new = get_bib(citekey)
	print(f'Processed record {str(processed_num)} of {str(len_new_bibs)} - {citekey}')
	processed_num = processed_num + 1
	mybib = mybib + '\n' + bib_new

print()
print('Updating recently modified records...')
print()
len_mod_bibs = len(mod_bibs)
processed_num = 1
for citekey in mod_bibs:
	updated_bib = get_bib(citekey)
	mybib = re.sub(r'@\w+\{' + citekey + ',.*?(?=\}\})\}\}', updated_bib.rstrip("\n"), mybib, 0, re.DOTALL)
	print(f'Processed record {str(processed_num)} of {str(len_mod_bibs)} - {citekey}')
	processed_num = processed_num + 1

f = open(bibpath, "w")
f.write(mybib)
f.close()

os.system('cat "' + bibpath + '" | /usr/local/bin/pandoc -f biblatex -t csljson > ' + jsonpath)

now_becomes_then = dt.today().strftime("%Y%m%d%H%M%S")

file = os.path.basename(__file__)

with open(file, "r") as this_file:
	data = this_file.readlines()
	
data[3] = "then = \"" + now_becomes_then + "\"\n"

with open(file, "w") as this_file:
	this_file.writelines( data )