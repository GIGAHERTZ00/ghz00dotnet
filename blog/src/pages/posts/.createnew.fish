#!/bin/fish

if not string length -q $argv[1]
  return 1
end

echo "---" >> $argv[1]
echo "layout:       ../../layouts/LayoutBlogMD.astro" >> $argv[1]
set line ""
while not string length -q $line
  echo "Title?"
  read line
end
echo "title:        \"$line\""                        >> $argv[1]
echo "createdDate:  $(date +%Y-%m-%dT%H:%M:%S)+09:00" >> $argv[1]
echo "updatedDate:  $(date +%Y-%m-%dT%H:%M:%S)+09:00" >> $argv[1]
set line ""
while not string length -q $line
  echo "Description?"
  read line
end
echo "description:  \"$line\""                        >> $argv[1]
set line ""
while not string length -q $line
  echo "Author?"
  read line
end
echo "author:       \"$line\""                        >> $argv[1]
set line ""
while not string length -q $line
  echo "Category?"
  read line
end
echo "category:     \"$line\""                        >> $argv[1]
set line ""
while not string length -q $line
  echo "Tags?"
  read line
end
set tags (string split ' ' $line)
set tags2 "["
for i in (seq (count $tags))
  set tags2 (string join '' $tags2 "\"" $tags[$i] "\"")
  if test $i -ne (count $tags)
    set tags2 (string join '' $tags2 ",")
  end
end
set tags2 (string join '' $tags2 "]")
echo "tags:         $tags2"                           >> $argv[1]
echo "---"                                            >> $argv[1]
#sed -i "s/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}/$(date -r $argv[1] +%Y-%m-%dT%H:%M:%S)/" $argv[1]
