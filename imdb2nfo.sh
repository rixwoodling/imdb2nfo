#!/bin/bash
# imdb2nfo v2 / creativecommons.org/licenses/BY-NC-ND/4.0

# This program automates the process of parsing IMDB movie information and outputs to a Kodi-compatible NFO file.
# It uses no special dependancies other than curl.

# Instructions
# 1. git clone https://github.com/rixwoodling/imdb2nfo.git
# 2. cd imdb2nfo
# 3. chmod 744 imdb2nfo.sh
# 4. imdb2nfo
#    | first enter IMDB id when prompted. then if NFO info looks correct, print to file when prompted.
#    | protip: create a bash alias to this bash script and run from any folder.
#    | Send bugs to https://github.com/rixwoodling/imdb2nfo/issues


# FUNCTIONS ---
# parse title from imdb and assign to function $(title):

#genre1() { <<< "$imdb" grep -A 2 \"genre\"\: | awk 'FNR == 2 {print}' | sed -e 's/^[ \t]*//' -e 's/"//' | sed -e 's/".*//' ; }
#genre2() { <<< "$imdb" grep -A 2 \"genre\"\: | awk 'FNR == 3 {print}' | sed -e 's/^[ \t]*//' -e 's/"//' | sed -e 's/".*//' ; }
# parentalguide
mpaa() { <<< "$imdbpg" grep certificates\=US | awk -F: '{print $2}' | sed 's/\".*//' | grep G\|PG\|PG-13\|R ; }
# releaseinfo
year() { <<< "$imdbri" grep og\:title | awk -F\" '{print $2}' | sed 's/.*\ (//' | sed 's/).*//' ; }
title() { <<< "$imdbri" grep og\:title | awk -F\" '{print $2}' | sed 's/).*//' | sed 's/\ (.*//' ; }
originaltitle() { <<< "$imdbri" grep -A1 \(original\ title\) | sed 's/<[^>]*>//g' | sed 's/^[ \t]*//' | awk 'FNR == 2 {print}' ; }
sorttitle() { <<< "$imdbri" grep og\:title | awk -F\" '{print $2}' | sed 's/).*//' | sed 's/\ (.*//' | sed -e 's/^The //' | sed 's/^A //' ; }
# plotsummary
plot() { <<< "$imdbps" grep "\<p\>.*" | awk 'FNR == 1 {print}' | sed 's/.*<p>//' | sed 's/<\/p>//' ; }
# technical
film() { <<< "$imdbt" grep -A3 Printed\ Film\ Format | awk 'FNR == 3 {print}' | sed 's/[ ]//g' ; }
aspectratio() { <<< "$imdbt" grep -A20 Aspect\ Ratio | awk 'FNR == 3 {print}' | sed 's/[ ]//g' ; }
# ratings
rating() { <<< "$imdbr" grep ipl-rating-star__rating | awk 'FNR == 1 {print}' | sed 's/[^0-9]*//' | sed 's/<.*//' ; }
# companycredits
studio() { <<< "$imdbcc" grep -A10 "Production\ Companies" | grep ^'>' | sed 's/^.//g' | sed 's/<[^>]*>.*//g' | awk 'FNR == 1 {print}' ; }
# fullcredits
director() { <<< "$imdbfc" grep -A100 "id\=\"director" | grep -B50 "id\=\"writer" | grep ^'>' | sed 's/^..//g' | awk 'FNR == 1 {print}' ; }
codirector() { <<< "$imdbfc" grep -A100 "id\=\"director" | grep -B50 "id\=\"writer" | grep ^'>' | sed 's/^..//g' | awk 'FNR == 2 {print}' ; } 
writer() { <<< "$imdbfc" grep -A100 "id\=\"writer" | grep -A100 "/name/nm" | grep -B50 "id\=\"cast" | grep ^'>' | sed 's/^..//g' | awk 'FNR == 1 {print}' ; }
cowriter() { <<< "$imdbfc" grep -A100 "id\=\"writer" | grep -A100 "/name/nm" | grep -B50 "id\=\"cast" | grep ^'>' | sed 's/^..//g' | awk 'FNR == 2 {print}' ; } 
actor0() { <<< "$imdbfc" grep -A100 'id\=\"cast\"' | grep ^'>\ ' | sed 's/^..//g' | awk 'FNR == 1 {print}' ; } 
actor1() { <<< "$imdbfc" grep -A100 'id\=\"cast\"' | grep ^'>\ ' | sed 's/^..//g' | awk 'FNR == 2 {print}' ; }
actor2() { <<< "$imdbfc" grep -A100 'id\=\"cast\"' | grep ^'>\ ' | sed 's/^..//g' | awk 'FNR == 3 {print}' ; }
actor3() { <<< "$imdbfc" grep -A100 'id\=\"cast\"' | grep ^'>\ ' | sed 's/^..//g' | awk 'FNR == 4 {print}' ; }

# create multiline xml and assign to variable named xml:
nfo() {
 echo "<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>"
 echo "<!-- $(title) $(year) -->"
 echo "<movie>"
 echo " <id>$id</id>"
 echo " <title>$(title)</title>"
 echo " <originaltitle>$(originaltitle)</originaltitle>"
 echo " <sorttitle>$(sorttitle)</sorttitle>"
 echo " <year>$(year)</year>"
 echo " <set>"
 echo "  <name></name>"
 echo " </set>"
 echo " <tag></tag>"
 echo " <tag></tag>"
 echo " <genre>$(genre1)</genre>"
 echo " <genre>$(genre2)</genre>"
 echo " <mpaa>$(mpaa)</mpaa>"
 echo " <userrating></userrating>"
 echo " <ratings>"
 echo "  <rating name='imdb' max='10' default='true'>"
 echo "   <value>$(rating)</value>"
 echo "   <votes></votes>"
 echo "  </rating>"
 echo " </ratings>"
 echo " <plot>$(plot)</plot>"
 echo ""
 echo " <!-- cast & credits -->"
 echo " <studio>$(studio)</studio>"
 echo " <director clear='true'>$(director)</director>"
 echo " <director>$(codirector)</director>"
 echo " <credits clear='true'>$(writer)</credits>"
 echo " <credits>$(cowriter)</credits>"
 echo " <actor>"
 echo "  <name>$(actor0)</name>"
 echo "  <order>0</order>"
 echo " </actor>"
 echo " <actor>"
 echo "  <name>$(actor1)</name>"
 echo "  <order>1</order>"
 echo " </actor>"
 echo " <actor>"
 echo "  <name>$(actor2)</name>"
 echo "  <order>2</order>"
 echo " </actor>"
 echo " <actor>"
 echo "  <name>$(actor3)</name>"
 echo "  <order>3</order>"
 echo " </actor>"
 echo ""
 echo " <!-- technical info -->"
 echo " <fileinfo>"
 echo "  <streamdetails>"
 echo "   <video>"
 echo "    <codec>VIDEO</codec>"
 echo "    <aspect>$(aspectratio)</aspect>"
 echo "    <film>$(film)</film>"
 echo "    <width>WIDTH</width>"
 echo "    <height>HEIGHT</height>"
 echo "    <durationinseconds>DURATION</durationinseconds>"
 echo "    <stereomode>STEREO</stereomode>"
 echo "   </video>"
 echo "   <audio>"
 echo "    <codec>AUDIO</codec>"
 echo "    <language>LANGUAGE1</language>"
 echo "    <channels>CHANNELS1</channels>"
 echo "   </audio>"
 echo "   <subtitle>"
 echo "    <language>SUB1</language>"
 echo "   </subtitle>"
 echo "   <subtitle>"
 echo "    <language>SUB2</language>"
 echo "   </subtitle>"
 echo "  </streamdetails>"
 echo " </fileinfo>"
 echo "</movie>"
 echo "https://www.imdb.com/title/tt$id/"
 echo ""
}


# MAIN CODE ---

# input imdb id
read -p "enter imdb id: tt" id
id="tt$id"

# 7 back to back server calls are made to imdb and page information is assigned to these variables 
imdbr=$(curl -s https://www.imdb.com/title/$id/ratings) ; printf '.' &&
imdbpg=$(curl -s https://www.imdb.com/title/$id/parentalguide) ; printf '.' &&
imdbri=$(curl -s https://www.imdb.com/title/$id/releaseinfo) ; printf '.' &&
imdbfc=$(curl -s https://www.imdb.com/title/$id/fullcredits) ; printf '.' &&
imdbps=$(curl -s https://www.imdb.com/title/$id/plotsummary) ; printf '.' &&
imdbcc=$(curl -s https://www.imdb.com/title/$id/companycredits) ; printf '.' &&
imdbt=$(curl -s https://www.imdb.com/title/$id/technical) ; echo '.' 

# sdout to verify all is correct before writing to file
echo "id: $id" && echo "title: $(title)" && 
echo "original title: $(originaltitle)" &&
echo "sort title: $(sorttitle)" && 
echo "year: $(year)" && 
echo "rated: $(mpaa)" &&
echo "description: $(plot)" && 
echo "genre: $(genre1)" && 
echo "genre: $(genre2)" &&
echo "rating: $(rating)" && 
echo "<--- cast & credits --->" && 
echo "studio: $(studio)" &&
echo "director: $(director)" && 
echo "co-director: $(codirector)" && 
echo "writer: $(writer)" &&
echo "co-writer: $(cowriter)" && 
echo "actor: $(actor0)" && 
echo "actor: $(actor1)" &&
echo "actor: $(actor2)" && 
echo "actor: $(actor3)" && 
echo "<--- technical info --->" &&
echo "aspect ratio: $(aspectratio)" && 
echo "film: $(film)" && 
echo "https://www.imdb.com/title/$id/" &&

# replace spaces in filename with periods
filename=$(echo "$(title) $(year)" | sed -e 's/ /./g' -e 's/[^[:alnum:].]\+//g' | sed 's/\.\./\./g')

# user input ( if yes, print xml to .nfo / if no, exit )
while true; do
	read -p "Output to ${filename}.nfo? (y/n): " yn
	case $yn in
		[Yy]* ) echo "$(nfo)" > ${filename}.nfo;;
		[Nn]* ) ;;
	esac

        echo ""
	echo "send issues and requests to:"
	echo "https://github.com/rixwoodling/imdb2nfo/issues"
        echo ""

# please donate to help out with development costs
#	echo ""
#	sleep 0.5s; echo "Be a HERO and donate to dev costs!"
#	sleep 0.5s; echo "BTC: 1BDsoLTwXhbuCBXWcouTB9ye1wfvZcbFGq"
#	sleep 0.5s; echo "DOGE: D8G9onJgca8aEH7Aq6aQFmhFHxpKtjnL3r"
#	sleep 0.5s;
#	echo ""
	exit;
done

# ---

