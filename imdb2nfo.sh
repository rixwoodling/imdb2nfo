#!/bin/bash
# imdb2nfo 2019 / creativecommons.org/licenses/BY-NC-ND/4.0

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
title() { <<< "$imdb" grep IMDb\<\/title\> | sed -e 's/<[^>]*>//g' -e 's/^[ \t]*//' | awk 'NF{NF-=3};1' ; }
originaltitle() { <<< "$imdb" grep originalTitle | sed -e 's/.*Title">//' -e 's/<.*//' ; }
sorttitle() { <<< "$imdb" grep IMDb\<\/title\> | sed -e 's/<[^>]*>//g' -e 's/^[ \t]*//' | sed -e 's/^The //' -e 's/^A //' | awk 'NF{NF-=3};1' ; }
year() { <<< "$imdb" grep IMDb\<\/title\> | sed -e 's/[^\(0-9\)]//g' -e 's/^.*(//' -e 's/).*//' ; }
film() { <<< "$imdbtt" grep -A 3 Printed\ Film\ Format | awk 'FNR == 3 {print}' | sed -e 's/^[ \t]*//' ; }
genre1() { <<< "$imdb" grep -A 2 \"genre\"\: | awk 'FNR == 2 {print}' | sed -e 's/^[ \t]*//' -e 's/"//' | sed -e 's/".*//' ; }
genre2() { <<< "$imdb" grep -A 2 \"genre\"\: | awk 'FNR == 3 {print}' | sed -e 's/^[ \t]*//' -e 's/"//' | sed -e 's/".*//' ; }
mpaa() { <<< "$imdb" grep contentRating | sed -e 's/.*: "//' | sed -e 's/".*//' ; }
plot() { <<< "$imdb" grep \"description\"\: | awk 'FNR == 1 {print}' | sed -e 's/\"description\"\: \"//' | sed -e 's/^[ \t]*//' -e 's/",.*//' | sed -e "s/u0027/\'/g" | sed -e 's/\\//g' | sed "s/$(title)//" | sed 's/^[^.]*. //' ; }
aspectratio() { <<< "$imdb" grep Aspect\ Ratio | sed -e 's/.*h4>//' -e 's/\ //g' ; }
rating() { <<< "$imdb" grep ratingValue | sed -e 's/.*: "//' -e 's/".*//' | awk 'FNR == 1 {print}' ; }
studio() { <<< "$imdbcc" grep -A 1 ttco_co_1 | awk 'FNR == 2 {print}' | sed -e 's/>//' -e 's/<[^>]*>//g' -e 's/  .*//' ; }
director() { <<< "$imdbfc" grep -A 12 "Directed" | tail -n 1 | sed 's/.*> //' ; }
codirector() { <<< "$imdbfc" grep -B 4 co-director | head -n 1 | sed 's/.*> //' ; }
writer() { <<< "$imdb" grep -A 2 "Writer" | tail -n 1 | sed -e 's/>//' -e 's/<.*//' ; }
cowriter() { <<< "$imdbfc" grep -A 1 ?ref_=ttfc_fc_wr2 | awk 'FNR == 2 {print}' | sed 's/.*> //' ; }
actor0() { <<< "$imdb" grep  "\"name\"\:" | sed -e 's/.*: "//' | sed -e 's/".*//' | awk 'FNR == 2 {print}' ; }
actor1() { <<< "$imdb" grep "\"name\"\:" | sed -e 's/.*: "//' | sed -e 's/".*//' | awk 'FNR == 3 {print}' ; }
actor2() { <<< "$imdb" grep "\"name\"\:" | sed -e 's/.*: "//' | sed -e 's/".*//' | awk 'FNR == 4 {print}' ; }
actor3() { <<< "$imdb" grep "\name\"\:" | sed -e 's/.*: "//' | sed -e 's/".*//' | awk 'FNR == 5 {print}' ; }

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
imdbfc=$(curl -s https://www.imdb.com/title/$id/fullcredits)
imdb=$(curl -s https://www.imdb.com/title/$id/?ref_=rvi_tt)
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
filename=$(echo "$(title) $(year)" | sed -e 's/ /./g' -e 's/[^[:alnum:].]\+//g' | sed 's/\.\./\./g')

# user input ( if yes, print xml to .nfo / if no, exit )
while true; do
	read -p "Output to ${filename}.nfo? (y/n): " yn
	case $yn in
		[Yy]* ) echo "$(nfo)" > ${filename}.nfo;;
		[Nn]* ) ;;
	esac
# please donate to help out with development costs
	echo ""
	sleep 1s; echo "Be a HERO and donate to dev costs!"
	sleep 0.5s; echo "BTC: 1BDsoLTwXhbuCBXWcouTB9ye1wfvZcbFGq"
	sleep 0.5s; echo "DOGE: D8G9onJgca8aEH7Aq6aQFmhFHxpKtjnL3r"
	echo ""
	exit;
done

# ---

