# el_tiempo_cli

## No need to unzip the file you download
 
 **Gems being used:**
 1. faraday
 2. nokogiri
 (You may have to install nokogiri)
 
## commands (run in the terminal): 

1. mkdir /tmp/mariacastro_interview_exercise
2. unzip /path/to/el_tiempo-master.zip -d /tmp/mariacastro_interview_exercise/
3. chmod 755 /tmp/mariacastro_interview_exercise/el_tiempo-master/eltiempo 
4. PATH="/tmp/mariacastro_interview_exercise/el_tiempo-master:$PATH"

**this last point needs to be repeated every time you open a new tab on the terminal**

**path/to -> real path for that file**

## make it work (run on terminal):
1. eltiempo -today 'Barcelona'
2. eltiempo -av_max 'Barcelona'
3. eltiempo -av_min 'Barcelona'

**Or any other municipality of Barcelona**
