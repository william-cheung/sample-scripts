#!/usr/bin/python

#
#  @file formatter.py
#  @author William Cheung
#  @date 2016/08/23 19:11:52
#  @brief 
# 

import urllib, urlparse, time

def format(url):
    fields = url.split('\001')
    fields[1] = urllib.unquote(fields[1])
    if filter(fields[1]):
        return None
    fields[0] = unix_time(fields[0])
    return ' '.join(fields)

def unix_time(data_str):
    tm = time.strptime(data_str[0:14], "%Y%m%d%H%M%S")
    return str(int(time.mktime(tm)))

def filter(url_str):
    url_obj = urlparse.urlparse(url_str);
    if ".google.com" in url_obj.hostname:
        return True
    return False

import sys
for line in sys.stdin:
    try:
        formatted = format(line)
        if formatted:
            sys.stdout.write(formatted)
    except:
        pass
