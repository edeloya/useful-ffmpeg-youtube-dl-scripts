@ECHO OFF
SET /p url="Paste YouTube URL: "
SET /p ss="Start (seconds or timecode): "
SET /p t="End (seconds or timecode): "
SET /p res="Resolution (# only): "

::piping youtube-dl STDOUT to findstr in the (''). Trouble chars in for loop escaped with ^ and with / in youtube-dl and findstr
::FOR loops through "tokens" in the findstr output, storing them for use with SET
::you can specify "tokens=3" to ONLY set vartmp to the 3rd "word" from the findstr output
FOR /f "tokens=*" %%a in ('youtube-dl "%url%" ^| findstr "[\"].*[\"]"') do (SET vartmp=%%a)
SET coolvid=%vartmp:~30%

::Takes full coolvid and cuts it by time into output.mp4. -y allows file overwrites. End the line with 2>nul to hide ffmpeg text
ffmpeg -ss %ss% -to %t% -i %coolvid% -vf "fps=15,scale=-2:%res%:flags=lanczos,split[s0][s1];[s0]palettegen=stats_mode=single[p];[s1][p]paletteuse" -loop 0 output.gif -y

::delet full video after
del %coolvid%
PAUSE

::more info at:
::https://ss64.com/nt/for_f.html
::https://ss64.com/nt/set.html
::https://ss64.com/nt/syntax-substring.html

::useful ffmpeg filters
::https://ffmpeg.org/ffmpeg-filters.html#Examples-142
::https://ffmpeg.org/ffmpeg-filters.html#scale-1

::-vf "scale=-2:360,setpts=0.5*PTS" -> -vf uses filters/params in QUOTES, delimited by COMMA
::scale=h:w, -n to make sure its a multiple of n (-2 tells it to autoscale to an even h at approx natural aspect ratio to 360)
::setpts=0.5*PTS, change presentation timestamp by multiple. .5*PTS speeds up video by 