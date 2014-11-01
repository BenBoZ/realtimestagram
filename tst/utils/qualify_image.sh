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

function check_inputs {

    if [[ "${INPUT_FILE}" == "" ]]; then
        echo "Please specify an input image with -i <input_file_path>"
        exit 1;
    fi

    if [[ "${OUTPUT_FILE}" == "" ]]; then
        echo "Please specify an output image with -o <output_file_path>"
        exit 1;
    fi
}

function qualify_rgb2hsv_image {

    check_inputs

    INPUT_FILE_BASE="${INPUT_FILE##*/}"
    REF_FILE="tmp/${INPUT_FILE_BASE%.*}_ref"

    # Create a reference file
    echo "Creating reference file"
    ./tst/utils/image_tool.sh -i ${INPUT_FILE} -o ${REF_FILE}  --create_HSV_image

    # Compare test output with reference file
    echo "Comparing reference file to test output"
    ./tst/utils/compare_images.sh -a ${OUTPUT_FILE} -e ${REF_FILE}".pnm"  --create_diff_stats_per_channel

}

function usage {

    printf "\n"
    printf "qualify_image.sh -i <file_path> -o <file_path> [opts] (--rgb2hsv)\n"
    printf "\n"
    printf "\tOptions:\n"
    printf "\t\t-i\t Test input file name [MANDATORY]\n"
    printf "\t\t-o\t Test output file name [MANDATORY]\n"
    printf "\t\t-u\t Print this message\n"
    printf "\n"
    printf "\tFunctions to qualify:\n"
    printf "\t\t--rgb2hsv\n"
    printf "\t\t        Qualifies the output from a rgb2hsv conversion using rgb input image\n"
    printf "\n"
}

while getopts :i:o:u-: option
do
    case "$option" in
    u)
         usage
         ;;
    i)  
         INPUT_FILE=$OPTARG
         ;;
    o)  
         OUTPUT_FILE=$OPTARG
         ;;
    -)
         case "${OPTARG}" in
             rgb2hsv)      qualify_rgb2hsv_image;;
             *)
                if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                    echo ""
                    echo "Unknown function to qualify --${OPTARG}" >&2
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

