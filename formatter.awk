#!/usr/bin/awk -f
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
  line = $0;
  
  sub(/&referer=/, " ", line);
  sub(/&ip=/, " ", line);
  sub(/&status=/, " ", line);
  
  n = split(line, splits, " ");
  if (n != 4 || filter(splits[1]))
    next;
  
  print line;
}

function filter(url) {
  if (length(url) == 0)
    return 1;
  for (i in invalid_endings) {
    if (index(url, invalid_endings[i]) > 0)
      return 1;
  }
  return 0;
}