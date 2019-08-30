#!/bin/bash
# imdb2nfo 2019 / creativecommons.org/licenses/BY-NC-ND/4.0

# This program automates the process of parsing IMDB movie information and outputs to a Kodi-compatible NFO file.
# It uses no special dependancies other than curl.

# Instructions
# 1. git clone https://github.com/rixwoodling/imdb2nfo.git
# 2. cd imdb2nfo
# 3. chmod 744 imdb2nfo.sh
# 4. imdb2nfo
# first enter IMDB id when prompted. then if NFO info looks correct, print to file
# protip: create a bash alias to this bash script and run from any folder!
# Send bugs to https://github.com/rixwoodling/imdb2nfo/issues

# ===

# -1- FUNCTIONS

# parse title from imdb and assign to function $(title):
title() {
 <<< "$imdb" grep IMDb\<\/title\> | sed -e 's/<[^>]*>//g' -e 's/^[ \t]*//' | awk 'NF{NF-=3};1'
}
# parse original title from imdb and assign to function $(originaltitle) if applicable:
originaltitle() {
 <<< "$imdb" grep originalTitle | sed -e 's/.*Title">//' -e 's/<.*//'
}
# parse sort title from imdb and assign to function $(sorttitle):
sorttitle() {
 <<< "$imdb" grep IMDb\<\/title\> | sed -e 's/<[^>]*>//g' -e 's/^[ \t]*//' | sed -e 's/^The //' -e 's/^A //' | awk 'NF{NF-=3};1'
}
# parse year from imdb and assign to function $(year):
year() {
 <<< "$imdb" grep IMDb\<\/title\> | sed -e 's/[^\(0-9\)]//g' -e 's/^.*(//' -e 's/).*//'
}
# parse film format from imdb and assign to function $(film):
film() {
 <<< "$imdbtt" grep -A 3 Printed\ Film\ Format | awk 'FNR == 3 {print}' | sed -e 's/^[ \t]*//'
}
# parse first genre from imdb and assign to function $(genre1):
genre1() {
 <<< "$imdb" grep -A 2 \"genre\"\: | awk 'FNR == 2 {print}' | sed -e 's/^[ \t]*//' -e 's/"//' | sed -e 's/".*//' 
}
# parse second genre from imdb and assign to function $(genre2):
genre2() {
 <<< "$imdb" grep -A 2 \"genre\"\: | awk 'FNR == 3 {print}' | sed -e 's/^[ \t]*//' -e 's/"//' | sed -e 's/".*//'
}
# parse mpaa rating from imdb and assign to function $(mpaa):
mpaa() {
 <<< "$imdb" grep contentRating | sed -e 's/.*: "//' | sed -e 's/".*//'
}
#
plot() {
 <<< "$imdb" grep \"description\"\: | awk 'FNR == 1 {print}' | sed -e 's/\"description\"\: \"//' | sed -e 's/^[ \t]*//' -e 's/",.*//'
}
#
aspectratio() {
 <<< "$imdb" grep Aspect\ Ratio | sed -e 's/.*h4>//' -e 's/\ //g'
}
#
rating() {
 <<< "$imdb" grep ratingValue | sed -e 's/.*: "//' -e 's/".*//' | awk 'FNR == 1 {print}'
}
#
studio() {
 <<< "$imdbcc" grep -A 1 ttco_co_1 | awk 'FNR == 2 {print}' | sed -e 's/>//' -e 's/<[^>]*>//g' -e 's/  .*//'
}
#
director() {
 <<< "$imdbfc" grep -A 1 ?ref_=ttfc_fc_dr1 | awk 'FNR == 2 {print}' | sed -e 's/[>\t]//' -e 's/ //'
}
#
writer() {
 <<< "$imdbfc" grep -A 1 ?ref_=ttfc_fc_wr1 | awk 'FNR == 2 {print}' | sed 's/.*> //'
}
#
cowriter() {
 <<< "$imdbfc" grep -A 1 ?ref_=ttfc_fc_wr2 | awk 'FNR == 2 {print}' | sed 's/.*> //'
}
#
codirector() {
 <<< "$imdbfc" grep -A 1 ?ref_=ttfc_fc_dr2 | awk 'FNR == 2 {print}' | sed 's/.*> //'
}
#
actor0() {
 <<< "$imdb" grep  "\"name\"\:" | sed -e 's/.*: "//' | sed -e 's/".*//' | awk 'FNR == 2 {print}'
}
#
actor1() {
 <<< "$imdb" grep "\"name\"\:" | sed -e 's/.*: "//' | sed -e 's/".*//' | awk 'FNR == 3 {print}'
}
#
actor2() {
 <<< "$imdb" grep "\"name\"\:" | sed -e 's/.*: "//' | sed -e 's/".*//' | awk 'FNR == 4 {print}'
}
#
actor3() {
 <<< "$imdb" grep "\name\"\:" | sed -e 's/.*: "//' | sed -e 's/".*//' | awk 'FNR == 5 {print}'
}

# -2- XML

# create multiline xml and assign to variable named xml:
read -r -d '' xml << "EOF"
<?xml version="1.0" encoding='UTF-8' standalone="yes" ?>

<!-- MOVIE YEAR -->
<movie>
 <id>IMDBID</id>
 <title>MOVIE</title>
 <originaltitle>OTITLE</originaltitle>
 <sorttitle>SORT</sorttitle>
 <year>YEAR</year>
 <set>
  <name></name>
 </set>
 <tag></tag>
 <tag></tag>
 <genre>GENRE1</genre>
 <genre>GENRE2</genre>
 <mpaa>RATED</mpaa>
 <userrating></userrating>
 <ratings>
  <rating name="imdb" max="10" default="true">
   <value>RATING</value>
   <votes></votes>
  </rating>
 </ratings>
 <plot>PLOT</plot>

 <!-- cast & credits -->
 <studio>STUDIO</studio>
 <director clear="true">DIRECTOR1</director>
 <director>DIRECTOR2</director>
 <credits clear="true">WRITER1</credits>
 <credits>WRITER2</credits>
 <actor>
  <name>ACTOR0</name>
  <order>0</order>
 </actor>
 <actor>
  <name>ACTOR1</actor>
  <order>1</order>
 </actor>
 <actor>
  <name>ACTOR2</actor>
  <order>2</order>
 </actor>
 <actor>
  <name>ACTOR3</actor>
  <order>3<order>
 </actor>

 <!-- technical info -->
 <fileinfo>
  <streamdetails>
   <video>
    <codec>VIDEO</codec>
    <aspect>ASPECT</aspect>
    <film>FILM</film>
    <width>WIDTH</width>
    <height>HEIGHT<height>
    <durationinseconds>DURATION</durationinseconds>
    <stereomode>STEREO</stereomode>
   </video>
   <audio>
    <codec>AUDIO</codec>
    <language>LANGUAGE1</language>
    <channels>CHANNELS1</channels>
   </audio>>
   <subtitle>
    <language>SUB1</language>
   </subtitle>
   <subtitle>
    <language>SUB2<language>
   </subtitle>
  </streamdetails>
 </fileinfo>
</movie>
EOF

# -3- XML + FUNCTIONS

# replace imdb values with sed and assign updated xml to function $(nfo):
nfo() {
 var=$(xml)
 echo "$var" | \
 sed "s/MOVIE/$(title)/g" | sed "s/SORT/$(sorttitle)/g" | sed "s/OTITLE/$(originaltitle)/g" | \
 sed "s/YEAR/$(year)/g" | sed "s/GENRE1/$(genre1)/g" | sed "s/GENRE2/$(genre2)/g" | \
 sed "s/IMDBID/$id/g" | sed "s/RATED/$(mpaa)/g" | sed "s/RATING/$(rating)/g" | \
 sed "s/PLOT/$(plot)/g" | sed "s/STUDIO/$(studio)/" | sed "s/DIRECTOR1/$(director)/g" | \
 sed "s/DIRECTOR2/$(codirector)/g" | sed "s/WRITER1/$(writer)/g" | sed "s/WRITER2/$(cowriter)/g" | \
 sed "s/ACTOR0/$(actor0)/g" | sed "s/ACTOR1/$(actor1)/g" | sed "s/ACTOR2/$(actor2)/g" | \
 sed "s/ACTOR3/$(actor3)/g" | sed "s/ASPECT/$(aspectratio)/g" | sed "s/FILM/$(film)/g"
}

# -4- MAIN

# input imdb id
read -p "enter imdb id: tt" id
id="tt$id"
imdb=$(curl -s https://www.imdb.com/title/$id/?ref_nv_sr_1)
imdbfc=$(curl -s https://www.imdb.com/title/$id/fullcredits/?ref_=tt_ov_st_sm)
imdbcc=$(curl -s https://www.imdb.com/title/$id/companycredits?ref_=ttloc_ql_4)
imdbtt=$(curl -s https://www.imdb.com/title/$id/technical?ref_=ttfc_ql_6)


# sdout to verify all is correct before writing to file
echo "id: $id" && echo "title: $(title)" && echo "original title: $(originaltitle)"
echo "sort title: $(sorttitle)" && echo "year: $(year)" && echo "rated: $(mpaa)"
echo "description: $(plot)" && echo "genre: $(genre1)" && echo "genre: $(genre2)"
echo "rating: $(rating)" && echo "<--- cast & credits --->" && echo "studio: $(studio)"
echo "director: $(director)" && echo "co-director: $(codirector)" && echo "writer: $(writer)"
echo "co-writer: $(cowriter)" && echo "actor: $(actor0)" && echo "actor: $(actor1)"
echo "actor: $(actor2)" && echo "actor: $(actor3)" && echo "<--- technical info --->"
echo "aspect ratio: $(aspectratio)" && echo "film: $(film)" && echo "https://www.imdb.com/title/$id/"


# replace spaces in filename with periods
filename=$(echo "$(title) $(year)" | sed -e 's/ /./g' -e 's/[^[:alnum:].]\+//g')


# user input ( if yes, print xml to .nfo / if no, exit )
while true; do
	read -p "Output to ${filename}.nfo? (y/n): " yn
	case $yn in
		[Yy]* ) echo "$(nfo)" > ${filename}.nfo;;
		[Nn]* ) ;;
	esac
# please donate to help out with development costs
	echo ""
	sleep 0.5s; echo "BTC: 1BDsoLTwXhbuCBXWcouTB9ye1wfvZcbFGq"
	sleep 0.5s; echo "DOGE: D8G9onJgca8aEH7Aq6aQFmhFHxpKtjnL3r";
	echo ""
	exit;
done

# ===


