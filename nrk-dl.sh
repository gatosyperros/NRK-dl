echo "This tool will attempt to extract a downloadable link from NRK"
#check if ffmpeg is installed
Check_ffmpeg=$(ffmpeg -version | grep -c Copyright)
if [ $Check_ffmpeg == 0 ]; then
        echo "Please make sure ffmpeg is installed on the system"
        read -rp "Please Enter Path to ffmpeg: " -e FFP
        Check_ffmpeg=$($FFP -version | grep -c Copyright)
        if [ $Check_ffmpeg == 0 ]; then
                echo "couldn't find ffmpeg on the system... exiting"
                return
        fi
else
        FFP="ffmpeg"
fi

#Pre check the variables skip asking if already passing
Check_Link=$(echo "$1" | grep -c nrk.no)
if [ $Check_Link == 0 ]; then
        read -rp "Please Enter Link From NRK: " -e LINK
else
        LINK=$1
fi

Check_Link=$(echo "$LINK" | grep -c nrk.no)
if [ $Check_Link == 0 ]; then
        echo "The script needs a link to function..."
        return
fi
ID=$(echo "$LINK" | grep -o '............$')
CMD=$(echo 'curl -m 10 -s https://psapi.nrk.no/playback/manifest/program')
echo "Fetching data please wait...."
curling=$(echo "$CMD/$ID")
$curling >nrk.info
Name=$(cat nrk.info | python -m json.tool  |grep -o "title.*.[a-z]" | cut -c 10-)

#Fetching Video Link
Check_Link=$(cat nrk.info | python -m json.tool  |grep  -c playlist)
if [ $Check_Link == 1 ]; then
        Video=$(cat nrk.info | python -m json.tool  |grep playlist | cut -c 25- | sed 's/..$//')
        Video_C="Found"
else
        Video_C=$(echo "Couldn't find video (probably time out) try again or contact the developer(s)")
        return
fi

#Fetching Subtitle link Link"
Check_Link=$(cat nrk.info | python -m json.tool  |grep  -c webVtt)
if [ $Check_Link == 1 ]; then
        Sub=$(cat nrk.info | python -m json.tool  |grep webVtt | cut -c 28- | sed 's/.$//')
        Sub_C="Found"
else
        Sub_C=$(echo "Couldn't find")
fi

echo ""
echo "#########################"
echo "This is what it found:"
echo "Title: $Name"
echo "$Video_C Video"
echo "$Sub_C Subtitles"
echo "#########################"
echo ""
echo "1: Download Video and Subtitles (default)"
echo "2: Download Only Video"
echo "3: Exit"

#experimental
#Video=$(echo $Video | sed 's/bw_low=10/bw_low=1000/g' | sed 's/bw_high=6000/bw_high=60000/g')

if [[ $Sub_C == "Found" ]]; then
        read -rp "Please select the next action: " -e -i 1 Choise
else
        read -rp "Please select the next action: " -e -i 2 Choise
fi

case $Choise in
        1)
                echo "Subtitles"
                wget $Sub -O $Name.vtt
                sleep 0.5
                echo "Video"
                $FFP -i "$Video" -c:v libx264 -preset slow -crf 22 "$Name.mp4"
                echo "Done"
                ;;
        2)
                echo "Video"
                $FFP -i "$Video" -c:v libx264 -preset slow -crf 22 "$Name.mp4"
                echo "Done"
                ;;
        3)
                echo "Exiting"
                return
                ;;
esac
