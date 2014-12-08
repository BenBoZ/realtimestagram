#!/bin/sh
#   This file is part of Realtimestagram.
#
#   Realtimestagram is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 2 of the License, or
#   (at your option) any later version.
#
#   Realtimestagram is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Realtimestagram.  If not, see <http://www.gnu.org/licenses/>.

BITDEPTH=8
WIDTH=512 
HEIGHT=512

# Creates pgm gray image where all color channels are averaged into single gray channel 
function create_gray_image {
    convert ${INPUT_FILE}                           \
            -resize ${WIDTH}x${HEIGHT}\!            \
            -compress none -depth ${BITDEPTH}       \
            -set colorspace Gray -separate -average \
            ${OUTPUT_FILE}
}

# Creates pnm color image
function create_color_image {
    convert ${INPUT_FILE}                           \
            -resize ${WIDTH}x${HEIGHT}\!            \
            -compress none -depth ${BITDEPTH}       \
            ${OUTPUT_FILE}
}

# Split all bit values into single lines
function split_gray {
    cat ${OUTPUT_FILE} | sed 1,3!d > ${OUTPUT_FILE}.tmp
    cat ${OUTPUT_FILE} | sed 1,3d | sed 's/ \+/\n/g' | sed '/^$/d' >> ${OUTPUT_FILE}.tmp

    cp -f ${OUTPUT_FILE}.tmp ${OUTPUT_FILE}
    rm -f ${OUTPUT_FILE}.tmp
}

# Split all rgb values into single lines
function split_color {
    cat ${OUTPUT_FILE} | sed 1,3!d > ${OUTPUT_FILE}.tmp
    cat ${OUTPUT_FILE} | sed 1,3d | sed 's/\([0-9]\+ [0-9]\+ [0-9]\+\) /\1\n/g' | sed '/^$/d' >> ${OUTPUT_FILE}.tmp

    cp -f ${OUTPUT_FILE}.tmp ${OUTPUT_FILE}
    rm -f ${OUTPUT_FILE}.tmp
}

function _create_HSV_image {
    
    convert $1 -colorspace HSB -set colorspace RGB $2 
    cat $2 | pnmtoplainpnm > $2.tmp
    
    cp -f $2.tmp $2
    rm -f $2.tmp
}

function split_HSV_image {
    
    FILE_EXTENSION="${1##*.}"

    HUE="${1%.*}_hue.${FILE_EXTENSION}"
    SAT="${1%.*}_sat.${FILE_EXTENSION}"
    VAL="${1%.*}_val.${FILE_EXTENSION}"

    convert $1 -channel R -separate ${HUE}.tmp 
    cat ${HUE}.tmp | pnmtoplainpnm > ${HUE}
    
    convert $1 -channel G -separate ${SAT}.tmp 
    cat ${SAT}.tmp | pnmtoplainpnm > ${SAT}
    
    convert $1 -channel B -separate ${VAL}.tmp 
    cat ${VAL}.tmp | pnmtoplainpnm > ${VAL}

    rm -f ${HUE}.tmp
    rm -f ${SAT}.tmp
    rm -f ${VAL}.tmp
}

function check_if_input_image {

    if [[ "${INPUT_FILE}" == "" ]]; then
        echo "Please specify an input image with -i <input_file_path>"
        exit 1;
    fi
}

function create_input_image_color {
   check_if_input_image
   create_color_image
   split_color
}

function create_input_image_gray {
   check_if_input_image
   create_gray_image
   split_gray
}

function create_split_HSV_images {

   check_if_input_image
   _create_HSV_image ${INPUT_FILE} ${OUTPUT_FILE}
   split_HSV_image ${OUTPUT_FILE}

   rm -f ${OUTPUT_FILE}
}

function create_HSV_image {
    
   check_if_input_image
   _create_HSV_image ${INPUT_FILE} ${OUTPUT_FILE}
   split_color
}

function usage {

    printf "\n"
    printf "image_tool.sh -i <file_path> [opts] --<action>\n"
    printf "\n"
    printf "\tOptions:\n"
    printf "\t\t-d\t Number of bits in the output image [default = ${BITDEPTH}]\n"
    printf "\t\t-h\t Height in number of pixels of the output image [default = ${HEIGHT}]\n"
    printf "\t\t-w\t Width in number of pixels of the output image [default = ${WIDTH}]\n"
    printf "\t\t-i\t Input file name [MANDATORY]\n"
    printf "\t\t-o\t Output file name [default = <input_file>.pnm]\n"
    printf "\t\t-u\t Print this message\n"
    printf "\n"
    printf "\tActions:\n"
    printf "\t\t--create_split_HSV_images\n"
    printf "\t\t                  Creates an separate image for Hue Saturation and Value channel\n"
    printf "\n"
    printf "\t\t--create_HSV_image\n"
    printf "\t\t                  Creates an image with R:Hue G:Saturation and B:Value channel\n"
    printf "\n"
    printf "\t\t--create_input_image_gray\n"
    printf "\t\t                  Creates an gray Netpbm image\n"
    printf "\n"
    printf "\t\t--create_input_image_color\n"
    printf "\t\t                  Creates an color Netpbm image\n"
    printf "\n"
}

while getopts :uh:w:i:o:cgr-: option
do
    case "$option" in
    u)
         usage
         ;;
    d)
         BITDEPTH=$OPTARG
         ;;
    h)
         HEIGHT=$OPTARG
         ;;
    w)
         WIDTH=$OPTARG
         ;;
    i)  
         INPUT_FILE=$OPTARG
         OUTPUT_FILE="${OPTARG%.*}_out.pnm"
         ;;
    o)  
         OUTPUT_FILE=$OPTARG.pnm
         ;;
    -)
         case "${OPTARG}" in
             create_split_HSV_images)
                create_split_HSV_images
                ;;

             create_HSV_image)
                create_HSV_image
                ;;

             create_input_image_gray)
                create_input_image_gray
                ;;

             create_input_image_color)
                create_input_image_color
                ;;
             *)
                if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                    echo "Unknown option --${OPTARG}" >&2
                    usage
                    exit 1
                fi
                ;;
         esac;;
    *)
        echo ""
        echo "ERROR: Invalid option: -${OPTARG}" 
        usage
        exit 1
        ;;
        esac
done

