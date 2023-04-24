#!/bin/zsh
#
# 
# Script	: ffmux.zsh
# Version	: v1.1.0
# Options	: see help
# Modified	: 12/2/23
#
# DESCRIPTION:
# Add (mux) an audio file containing one audio stream with another file containing both video, audio and/or subtitles.
#
# This script was written to allow for the addition of a director's commentary to an existing movie video file.
# The video and audio from both files are muxed into a new media file containing all of the video, audio and subtitle
# streams from the first file and the (single) audio stream contained in the second file.
#
# Date		Modification notes
# ----		------------------
# 2/10/22	Script start
# 2/1/23	Added "-info" and "-help" options.
# 20/1/23	Added "-debug" and logs.
# 13/2/23	Added new stream type: (video) menu text
# 14/2/23	Added check to ensure output filetype matches source media filetype.
# 18/2/23	Modified order in help screen.
# 24/3/23	Corrected some code comments and added the paragraph starting "If you
# 		encounter problems...." to the help section.
# 23/4/23	Added the "-error" option.
# 
# http://youtube.com/greenflarevideos (October 2022) 
# 
progname=$(basename $0)
DEBUG_DIR="$HOME"


# ---- Start user input checks ---
#
# The first two checks are for the -help and the -error options. If either of these options are
# selected, an information screen is displayed.

if [[ "$1" == "--help" ]] || [[ "$1" == "-help" ]]; then
	echo "$progname: --help\n"
cat <<!!
  Name: ffmux.zsh - Mux media files.

  Usage:
  $progname <source media file> <source audio file> <target media file>
  $progname [-info] <source media file>
  $progname [-help]
  $progname [-error]

  Description:
  Combine a media file containing one or more media streams <source media file> with a media file that contains a single audio
  stream <source audio file> to create a new media file <target media file> that contains streams from both files.

  arguments:

	<source media file>
		This file MUST contain a valid video stream. The media file can contain any number of additional media
	 	streams (audio streams, cover art streams, subtitle streams etc). Any video type files can be specified
		eg. mp4, mkv, mov, avi. The audio stream contained in <source audio file> will be added (muxed) as the last
		media stream within the <target media file>.

	<source audio file>
		This file MUST contain a valid audio stream. The following audio type files can be specified: m4a, mp3
		and ac3. It is generally accepted that the most suitable audio format for "muxing" is type "(aac) m4a". The
		first audio stream will always be selected if the audio file contains more than one media stream (a cover art
		stream, for example).

	<target media file>
		The new media file that will contain all media streams from <source media file> and the (single) audio
		stream contained in <source audio file>. The file should be of the same video type as <source video file>.

  Other functions: 

	--help
		Display help
	--info
		Display information about media stream(s) within <source media file>

	--debug
		Display last ffmpeg command (for debug)
	--error
		Display error correcting routine

  If filenames contain spaces, they must be surrounded by double quotes. Special characters such as * and ? etc are not allowed.
  The program allows for a maximum of 9 media streams in <source media file>.

  If you encounter problems, you should initially run the "--info" option for both the video (source) file and the audio file
  (the m4a audio file, that is). You may find that there is an unrecognised stream in one of these files. You can report this
  stream as an issue, and this will be included in a future release.

  Examples:
	$progname Failsafe.mp4 failsafe_commentary.m4a Failsafe_with_commentary.mp4
		Combine media streams in the file "Failsafe.mp4" with the audio stream in "failsafe_commentary.m4a" and write these
		media streams to the new (target) media file "Failsafe_with_commentary.mp4"
			
	$progname -info Failsafe_commentary.m4a
		Display media stream information for file "Failsafe_commentary.m4a"

!!

# The double exclamation mark above indicates the end of the information screen.
	exit 0
fi

# Display error correcting information screen.
if [[ "$1" == "--error" ]] || [[ "$1" == "-error" ]]; then
cat <<!! | more


  ffmux.zsh - media stream errors

  Follow these steps when an ffmpeg stream error is reported:

  1. An error is encountered during ffmpeg execution.
  # ffmux.zsh ""Black_Hawk_Down.mp4" -i "bhd_comm_track.m4a" "bhdc.mp4"

  Command output (excerpt) ...
    Duration: 00:11:23.13, start: 0.000000, bitrate: 129 kb/s
      Stream #1:0(und): Audio: aac (LC) (mp4a / 0x6134706D), 44100 Hz, stereo, fltp, 127 kb/s (default)
      Metadata:
        handler_name    : Stereo

  [mp4 @ 0x7fd4c6036800] track 1: codec frame size is not set
  [mp4 @ 0x7fd4c6036800] Could not find tag for codec eia_608 in stream #3, codec not currently supported in container
  Could not write header for output file #0 (incorrect codec parameters ?): Invalid argument

  Stream mapping:
    Stream #0:0 -> #0:0 (copy)
    Stream #0:1 -> #0:1 (copy)
    Stream #0:2 -> #0:2 (copy)
    Stream #0:3 -> #0:3 (copy)
    Stream #0:4 -> #0:4 (copy)
    Stream #1:0 -> #0:5 (copy)
      Last message repeated 1 times

  ffmux.zsh: ** Problems encountered, check with 'ffmux.zsh -debug' & retry **


  2. Run debug command.
  # ffmux.zsh -debug

  Last ffmux execution (Thu 20 Apr 2023 17:56:22 BST): 

  File (Black_Hawk_Down.mp4) info:
    Stream #0:0(eng): Audio: aac (LC) (mp4a / 0x6134706D), 48000 Hz, stereo, fltp, 126 kb/s (default)
    Stream #0:1(eng): Audio: ac3 (ac-3 / 0x332D6361), 48000 Hz, 5.1(side), fltp, 384 kb/s
    Stream #0:2(eng): Video: h264 (Main) (avc1 / 0x31637661), yuv420p, 1280x532, 4200 kb/s, SAR 1:1 DAR 320:133, 23.98 fps, 23.98 tbr, 24k tbn, 50 tbc (default)
    Stream #0:3(eng): Subtitle: eia_608 (c608 / 0x38303663), 1280x532, 0 kb/s
    Stream #0:4: Video: mjpeg (Baseline), yuvj420p(pc, bt470bg/unknown/unknown), 400x600 [SAR 1:1 DAR 2:3], 90k tbr, 90k tbn, 90k tbc (attached pic)
    Stream #0:5(und): Data: bin_data (text / 0x74786574)

  File (bhd_comm_track.m4a) info:
    Stream #0:0(und): Audio: aac (LC) (mp4a / 0x6134706D), 48000 Hz, stereo, fltp, 196 kb/s (default)

  Command generated for execution:
  ffmpeg -i "Black_Hawk_Down.mp4" -i "bhd_comm_track.m4a" -map 0:0 -map 0:1 -map 0:2 -map 0:3 -map 0:4 -map 1:0 -c copy -disposition:a
  -default -disposition:a:0 default -disposition:v -default -disposition:v:0 default "bhdc.mp4"

  ** Errors encountered during ffmpeg execution !

  -- End debug --


  3. Review ffmpeg error report:
   track 1: codec frame size is not set
  [mp4 @ 0x7f7d9501fa00] Could not find tag for codec eia_608 in stream #3, codec not currently supported in container
  Could not write header for output file #0 (incorrect codec parameters ?): Invalid argument
  #
  #

  NOTE: This error (also reported in point 1 above) specifies that ffmpeg could not find the tag for "codec eia_608 in stream #3".
  "#3" here refers to the name/reference of the stream and not the ordinal stream number. ffmpeg therefore encounters an error in the
  subtitle stream ie. ie. the line in the info listing above, starting "Stream #0:3(eng)..." of the file #0. "file #0" here does
  refer to the ordinal file number ie. the first file, the <source media file>.


  4.Remove the "problem" stream and re-execute the ffmpeg command:
  # ffmpeg -i "Black_Hawk_Down.mp4" -i "bhd_comm_track.m4a" -map 0:0 -map 0:1 -map 0:2 -map 0:4 -map 0:5 -map 1:0 -c copy -disposition:a
  -default -disposition:a:0 default -disposition:v -default -disposition:v:0 default "bhdc.mp4"

  ... command execution success

  Note: To address the error in the "problem" stream, we discard use of the "ffmux.zsh" script and execute the generated ffmpeg
  command displayed in the debug file (excluding the media stream that causes the error).


!!
# the double exclamation mark above indicates the end of the information screen.
	exit 0
fi

# Display information from last ffmpeg execution.
if [[ "$1" == "--debug" ]] || [[ "$1" == "-debug" ]]; then
	if [ ! -f $DEBUG_DIR/ffmux.debug ]; then
		echo "Last ffmux execution: " > $DEBUG_DIR/ffmux.debug
		echo "Awaiting first ffmpeg execution ...\n" >> $DEBUG_DIR/ffmux.debug
		cat $DEBUG_DIR/ffmux.debug
		exit 0
	else
		cat $DEBUG_DIR/ffmux.debug
		echo "\n"
		exit 0
	fi
fi

# If the "-info" option is selected and no media file is provided, abort the script.
if [ $# -lt 2 ] && [[ "$1" == "-info" ]];then
	echo "$progname: ERROR: -info option: please provide a <source media file>"
	exit 0
fi

if [ $# -lt 2 ]; then
	usage_msg+="...<source media file> <source audio file> <target media file> eg. $progname Failsafe.mp4 Failsafe_commentary.m4a Fail_Safe_with_commentary.mp4" 
	echo "$progname: usage: $usage_msg"
	echo "help available ($progname --help)."
	exit 1
fi

f="$1"					# full filename of first file
f2="$2"					# full filename of second file
nvtitle="$3"				# full filename of new video/media file
max_streams=0				# control variable
info_requested=0			# the "--info" option has not been requested

# Info option
if [[ "$1" == "--info" ]] || [[ "$1" == "-info" ]]; then
	info_requested=1
	shift;
	f="$1"
fi

# Check for "f" (first file) existence.
if [ ! -f "$f" ]; then
	echo "ERROR: source media file ($f) not found, aborting ..."
	exit 0
fi

# If the "-info" switch has been chosen, check if the media file is audio or video.
# If stream is not video OR stream is not audio, then report error.
video_stream_exists=$(ffmpeg -i "$f" 2>&1 | awk '/Stream\ #0/ && /Video/ { print $0 }')
audio_stream_exists=$(ffmpeg -i "$f" 2>&1 | awk '/Stream\ #0/ && /Audio/ { print $0 }')
if [[ "$video_stream_exists" == "" ]] && [[ "$audio_stream_exists" == "" ]] && (($info_requested == 1)); then
	echo "ERROR: File ($f1) does not contain video/audio, aborting ..."
	exit 0
fi

# Display file stream information if the "-info" switch has been requested.
if (($info_requested == 1)); then
	stream_info=$(ffmpeg -i "$f" 2>&1 | awk '/Stream\ #/ { print $0 }')
	echo "Stream information..."
	echo $stream_info
	exit 0
fi

# Check for "f2" (second file) existence.
if [ ! -f "$f2" ]; then
	echo "ERROR: source audio file ($f2) not found, aborting ..."
	exit 0
fi

# ---- End user input checks ---


# ---- Start file content checks ---
# If the script has reached this point, the user has requested the "muxing" option. Check for valid video file.
video_stream_exists=$(ffmpeg -i "$f" 2>&1 | awk '/Stream\ #0/ && /Video/ { print $0 }')
if [[ "$video_stream_exists" == "" ]]; then
	echo "ERROR: Video file ($f) contains no video, aborting ..."
	exit 0
else
	# Check that the filetypes (mp4, mkv etc) match for the source and target media files.
	#
	# find the file extension of the source media file.
	source_filename=$(basename "$f")
	source_media_file_ext="${source_filename##*.}"

	# find the file extension of the target media file.
	target_filename=$(basename "$nvtitle")
	target_media_file_ext="${target_filename##*.}"

	if [[ "$source_media_file_ext" == "$target_media_file_ext" ]]; then

		# Start the "Last execution" log.
		if [ -f $DEBUG_DIR/ffmux.debug ]; then
			now=$(date)
			echo "\nLast ffmpeg execution ($now): " > $TMPDIR/ffmux_debug$$
		fi

		echo "\nFile ($f) info:" >> $TMPDIR/ffmux_debug$$
		f_stream_info=$(ffmpeg -i "$f" 2>&1 | awk '/Stream\ #/ { print $0 }')
		echo "$f_stream_info" >> $TMPDIR/ffmux_debug$$
		echo "\n" >> $TMPDIR/ffmux_debug$$

	else
		echo "ERROR: the filetypes ($source_media_file_ext) for \"$f\" and \"$nvtitle\" do not match, aborting ..."
		exit 0
	fi
fi

# Check for valid audio file
audio_stream_exists=$(ffmpeg -i "$f2" 2>&1 | awk '/Stream\ #0/ && /Audio/ { print $0 }')
if [[ "$audio_stream_exists" == "" ]]; then
	echo "ERROR: Audio file ($f2) incompatible, aborting ..."
	exit 0
else
	echo "File ($f2) info:" >> $TMPDIR/ffmux_debug$$
	f2_stream_info=$(ffmpeg -i "$f2" 2>&1 | awk '/Stream\ #/ { print $0 }')
	echo "$f2_stream_info" >> $TMPDIR/ffmux_debug$$
	echo "\n" >> $TMPDIR/ffmux_debug$$
fi


# Check the second file for streams. If it contains more than one stream, choose the first audio stream.
# Note that the second file may contain an audio stream and a cover art stream - this cover art stream
# does not appear on some applications eg. the "mediainfo" application.
f2_more_than_one_stream=0;
number_file2_streams=$(ffmpeg -i "$f2" 2>&1 | awk '/Stream\ #/ { count++; } END { print count }')
number_file2_streams=$(( $number_file2_streams + 0 ))	# force conversion to integer
if (($number_file2_streams != 1)); then
	f2_more_than_one_stream=1;

	# Check the second file for the number of audio streams. If it contains more that one stream,
	# warn the user that the first will be chosen. Then determine which stream is the first audio stream.
	# It is not possible (as at January 2023) for an audio file to have more than one audio stream, I believe.
	# The following is included (just in case).
	number_file2_audio_streams=$(ffmpeg -i "$f2" 2>&1 | awk '/Stream\ #/ && /Audio/ { count++; } END { print count }')
	number_file2_audio_streams=$(( $number_file2_audio_streams + 0 ))
	
	if (($number_file2_audio_streams != 1)); then
		echo "WARNING: File \"$f2\" has more than one audio stream !"
		echo "The first audio stream will be selected.\n"
		echo "Continue? (y/n):\c"
		read ans
		if [[ "$ans" = "n" ]] || [[ "$ans" = "N"  ]]; then
			echo "\nProgram aborted."
			exit 0
		else
			echo "\nContinuing Muxing ...\n"
		fi
	fi
else
	# There is only one stream in the second file. Set the map string accordingly.
	new_map_number="0"
	new_audio_map_string="-map 1:${new_map_number}"

fi

# If the script has progressed this far and the following conditional is true, then the audio file has (more than likely) one
# audio stream and one or more "other" media streams (cover art, for example). The first instance of an audio stream will be
# selected for muxing.
if (($f2_more_than_one_stream == 1)); then

	# Process the ffmpeg stream output of the "f2" file and determine the line number in which the audio stream
	# appears. This number will determine the <target media file> mapping command ie. the value of the variable
	# "new_audio_map_string".
	ffmpeg -i "$f2" 2>&1 | awk '/Stream\ #/ { print $0 }' > $TMPDIR/ffmux$$
	lnumber=1
	while read line_details; do
		if [[ $line_details == *Stream\ #* && $line_details == *Audio* ]]; then
			break;
		fi
		lnumber=$(( $lnumber + 1 ))
	done < $TMPDIR/ffmux$$


	# As an example, if the audio stream in file " $f2" is listed second, the mapping
	# is one less ie. the ffmpeg mapping is "-map 1:1".
	new_map_number=$(( $lnumber - 1 ))
	new_audio_map_string="-map 1:${new_map_number}"
fi

# The following checks that there is just one "major" video stream in $f (file one) ie. a moving picture video stream.
# This should not occur; it is included (just in case).
number_video_streams=$(ffmpeg -i "$f" 2>&1 | awk '/Stream\ #0/ && /Video/ { print $0 }'| grep -v mjpeg | wc -l)
number_video_streams=$(( $number_video_streams + 0 )) # force conversion to integer

if (($number_video_streams != 1)); then
	echo "WARNING: More than one primary video stream found. Problems may occur !"
	echo "Continue? (y/n):\c"
	read ans
	if [[ "$ans" = "n" ]] || [[ "$ans" = "N"  ]]; then
		echo "\nProgram aborted."
		exit 0
	else
		echo "\nContinuing Muxing ...\n"
	fi
fi

# In the first file ($f), we determine the differing media stream contained in the file:
#
# the number of audio streams
# the number of subtitle streams
# the number of (video) menu text streams
#
# We then add 1 for the video stream which gives us the total number of streams in the first file.
number_audio_streams=$(ffmpeg -i "$f" 2>&1 | awk '/Stream\ #0/ && /Audio/ { count++; } END { print count }')

number_subtitle_streams=$(ffmpeg -i "$f" 2>&1 | awk '/Stream\ #0/ && /Subtitle/ { count++; } END { print count }')
number_text_streams=$(ffmpeg -i "$f" 2>&1 | awk '/Stream\ #0/ && /Data: bin_data/ { count++; } END { print count }')
number_va_streams=$(( $number_audio_streams + $number_text_streams + $number_subtitle_streams + 1 ))

# The number of "map commands" in each option below is determined by the total streams contained in $f (file one).
# For example, if there are three media streams in $f (file one), there will be four map commands. Three map commands
# for the streams in the first file and an extra map command for the audio being added.  Note: if there is only one
# media stream in $f (file one), by definition this MUST be a video stream. In such a case, it follows that 
# $f (file one) has no audio stream.
case $number_va_streams in
	(1)
		first_map_string="-map 0:0"
	;;
	(2)
		first_map_string="-map 0:0 -map 0:1"
	;;
	(3)
		first_map_string="-map 0:0 -map 0:1 -map 0:2"
	;;
	(4)
		first_map_string="-map 0:0 -map 0:1 -map 0:2 -map 0:3"
	;;
	(5)
		first_map_string="-map 0:0 -map 0:1 -map 0:2 -map 0:3 -map 0:4"
	;;
	(6)
		first_map_string="-map 0:0 -map 0:1 -map 0:2 -map 0:3 -map 0:4 -map 0:5"
	;;
	(7)
		first_map_string="-map 0:0 -map 0:1 -map 0:2 -map 0:3 -map 0:4 -map 0:5 -map 0:6"
	;;
	(8)
		first_map_string="-map 0:0 -map 0:1 -map 0:2 -map 0:3 -map 0:4 -map 0:5 -map 0:6 -map 0:7"
	;;
	(9)
		first_map_string="-map 0:0 -map 0:1 -map 0:2 -map 0:3 -map 0:4 -map 0:5 -map 0:6 -map 0:7 -map 0:9"
	;;

	(*)
		max_streams=1

esac

if ((max_streams == 1)); then
	echo "\nMore than the maximum of 9 audio streams detected, aborting ...\n"
	exit 0
fi

# Build the ffmpeg command based on media input streams above.
ffcmd="ffmpeg -i \"$f\" -i \"$f2\" "
ffcmd+="$first_map_string "
ffcmd+="$new_audio_map_string "
ffcmd+="-c copy -disposition:a -default -disposition:a:0 default -disposition:v -default -disposition:v:0 default \"$nvtitle\""

# The command that is to be executed is echoed to the standard output - it is prefixed with an arrow to
# make it more easily locatable after the ffmpeg process has been executed.
echo "		 --------> $ffcmd"

# Update the log.
echo "Command generated for execution:" >> $TMPDIR/ffmux_debug$$
echo "$ffcmd" >> $TMPDIR/ffmux_debug$$

echo "Preparing to mux media files ..."
eval "$ffcmd"
if (( ? )) then
	# execution failed
	echo "\n ${progname}: ** Problems encountered, check with '$progname -debug' & retry **"
	echo "\n** Errors encountered during ffmpeg execution !\n" >> $TMPDIR/ffmux_debug$$
	cp $TMPDIR/ffmux_debug$$ $DEBUG_DIR/ffmux.debug
	rm -f "$nvtitle" 2>/dev/null
	exit 1
else
	# execution succeeded
	# Print the "-info" data for the <target media file> to the log.
	echo "\nFile ($nvtitle) info:" >> $TMPDIR/ffmux_debug$$
	nvtitle_stream_info=$(ffmpeg -i "$nvtitle" 2>&1 | awk '/Stream\ #/ { print $0 }')
	echo "$nvtitle_stream_info" >> $TMPDIR/ffmux_debug$$
	echo "\n" >> $TMPDIR/ffmux_debug$$
	echo "\nMuxing complete - double check integrity with Handbrake (or similar) !!"
	cp $TMPDIR/ffmux_debug$$ $DEBUG_DIR/ffmux.debug
fi

rm -f $TMPDIR/ffmux$$ $TMPDIR/ffmux_debug$$

exit 0
