#!/usr/bin/env bash
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


TEST_INPUT_FOLDER="tst/input"
TEST_OUTPUT_FOLDER="tst/output"
TEST_SCRIPTING="tst/utils"

TESTSET_FOLDER="bld"

## @fn run_sepia_test()
## @brief Runs sepia test
run_sepia_test() {

    # Run the test set
    echo "> Running sepia tests"
    $TESTSET_FOLDER/sepia_testsets_tb

    SEPIA_TEST_RESULT=0

    # Qualify the results
    echo "> Qualifying sepia tests"
    for image in lenna windmill danger_zone amersfoort rainbow hue_gradient sat_gradient val_gradient
    do
        INPUT_IMAGE="$TEST_INPUT_FOLDER/$image.pnm"
        OUTPUT_IMAGE="$TEST_OUTPUT_FOLDER/sepia_$image.pnm"

        $TEST_SCRIPTING/qualify_image.sh -i $INPUT_IMAGE -o $OUTPUT_IMAGE --sepia

        result=$?

        if [ $result != 0 ]
        then
           SEPIA_TEST_RESULT=1
        fi
    done

    return $SEPIA_TEST_RESULT
}

## @fn run_rgb2hsv_test()
## @brief Runs rgb2hsv test
run_rgb2hsv_test() {

    # Run the test set
    echo "> Running rgb2hsv tests"
    $TESTSET_FOLDER/rgb2hsv_testsets_tb

    RGB2HSV_TEST_RESULT=0

    # Qualify the results
    echo "> Qualifying rgb2hsv tests"
    for image in lenna windmill danger_zone amersfoort rainbow hue_gradient sat_gradient val_gradient
    do
        INPUT_IMAGE="$TEST_INPUT_FOLDER/$image.pnm"
        OUTPUT_IMAGE="$TEST_OUTPUT_FOLDER/rgb2hsv_$image.pnm"

        $TEST_SCRIPTING/qualify_image.sh -i $INPUT_IMAGE -o $OUTPUT_IMAGE --rgb2hsv

        result=$?

        if [ $result != 0 ]
        then
           RGB2HSV_TEST_RESULT=1
        fi
    done

    return $RGB2HSV_TEST_RESULT
}
run_sepia_test
SEPIA_RESULT=$?

run_rgb2hsv_test
RGB2HSV_RESULT=$?

if [[ $((SEPIA_RESULT + RGB2HSV_RESULT)) -ne 0 ]]
then 
   echo "FAIL: Some tests failed"
   exit 1
else
   echo "PASS: All tests passed"
   exit 0
fi



