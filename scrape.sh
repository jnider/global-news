#!/bin/bash
#
# 2021-12-16 J.Nider

#today=$(date +%F)
targetdir=/mnt/data/public/video/global
mkdir -p $targetdir

# scrape URLs for videos from global news web pages
rm -f index.html
rm -f urls

# grab the main page to find the playlist URLs
wget --no-check-certificate globalnews.ca

# extract the playlist ids
ids=($(grep -m1 '/playlist/' index.html | sed -E 's/^.*playlist\/(.*)[,\/].*/\1/g' | sed -E 's/,/\n/g'))
#echo ${ids[*]}

# for each id, download the URL list
for id in ${ids[*]}; do
	url=https://globalnews.ca/video/embed/playlist/$id
	echo $url
	wget --no-check-certificate $url

	# step 1: break into lines, with URL at the beginning
	sed -E 's/"file":/\n/g' $id > part1

	# step 2: filter out the URL from the line
	grep -E '^"https' part1 | sed -E 's/^"(https:.*\.mp4)".*/\1/g' > raw1

	# step 3: replace \/ with /
	sed -E 's/\\\//\//g' raw1 >> urls

	# remove the temporary files
	rm $id
done
rm -f part1 raw1

# download all videos that don't already exist
wget --no-check-certificate -nc -i urls -P $targetdir
