#!/usr/bin/awk --posix -f
BEGIN {
  invalid_endings[1] = ".jpg";
  invalid_endings[2] = ".jpeg"; 
  invalid_endings[3] = ".png"; 
  invalid_endings[4] = ".gif"; 
  invalid_endings[5] = ".js"; 
  invalid_endings[6] = ".css"; 
  invalid_endings[7] = ".swf"; 
  invalid_endings[8] = ".apk"; 
}
{
  line = $0
  
  sub(/&referer=/, " ", line)
  sub(/&ip=/, " ", line)
  sub(/&status=/, " ", line)
  
  n = split(line, fields, " ")
  if (n != 4 || filter(fields))
    next
  
  print line
}

function filter(fields) {
  if (check_url(fields[1]) != 1)
    return 1
  if (fields[2] != "-" && fields[2] != "NULL" && check_url(fields[2]) != 1)
    return 1
  if (check_ip(fields[3]) != 1)
    return 1
  return 0
}

function check_url(url) {
  if (length(url) == 0)
    return 0
  for (i in invalid_endings) {
	if (end_with(url, invalid_endings[i]))
      return 0
	if (end_with(url, toupper(invalid_endings[i])))
	  return 0
  }

  regex = "^((http|https|ftp)://)?[0-9a-zA-Z]+([.][0-9a-zA-Z]+)+/"
  if (match(url, regex) != 1)
    return 0
  return 1
}

function check_ip(ip) {
  n = split(ip, splits, ".")
  if (n != 4)
    return 0

  regex =  "^([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
  for (i = 1; i <= n; i++) {
    if (match(splits[i], regex) != 1)
      return 0	
  }
  return 1
}

function end_with(str, end) {
  i = index(str, end)
  if (i > 0 && length(end) + i == length(str) + 1)
    return 1
  return 0
}

function urldecode(url) {
  command = sprintf("echo %s | sh urldecoder.sh", url)
  command | getline result
  return result
}
