SETLOCAL
set clipDelay=%3
set /A factor3D=20
set factorTimeOffset=%clipDelay%
set encoder=hevc_nvenc
set rateControl=cbr
set bitRate=15M
set minBitRate=15M
set maxBitRate=15M
set bufferSize=512K

REM The line below is intended to extract the width and height of the video automatically. 
REM Comment the line out and set the videoW and videoH variables explicitly if this does not work for your video.
for /f "delims=" %%a in ('ffprobe -hide_banner -show_streams %1 2^>nul ^| findstr "^width= ^height="') do set "mypicture_%%a"

set videoW=%mypicture_width%
set videoH=%mypicture_height%

set /A ResW=%videoW%+%videoW%/%factor3D%
set /A videoH=%videoH%+%videoH%/%factor3D%
set /A CropW=(%ResW%-%videoW%)/2

IF EXIST right_eye.mp4 DEL /F right_eye.mp4

ffmpeg -i %1 -vf "scale=%ResW%:%videoH%,crop=%videoW%:%videoH%:0:0" -c:v %encoder% -rc %rateControl% -b:v %bitRate% -minrate %minBitRate% -maxrate %maxBitRate% -bufsize %bufferSize% -c:a aac -ss %factorTimeOffset% right_eye.mp4

IF EXIST left_eye.mp4 DEL /F left_eye.mp4

ffmpeg -i %1 -vf "scale=%ResW%:%videoH%,crop=%videoW%:%videoH%:%CropW%:0" -c:v %encoder% -rc %rateControl% -b:v %bitRate% -minrate %minBitRate% -maxrate %maxBitRate% -bufsize %bufferSize% -c:a aac left_eye.mp4

IF EXIST %2.SBS.mp4 DEL /F %2.SBS.mp4

ffmpeg -i left_eye.mp4 -vf "movie=right_eye.mp4 [in1]; [in]pad=iw*2:ih:iw:0[in0]; [in0][in1] overlay=0:0 [out]" -c:v %encoder% -rc %rateControl% -b:v %bitRate% -minrate %minBitRate% -maxrate %maxBitRate% -bufsize %bufferSize% %2.SBS.mp4

DEL /F right_eye.mp4

DEL /F left_eye.mp4

EXIT /B
