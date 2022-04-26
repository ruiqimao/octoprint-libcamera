#!/bin/sh
input="input_libcamera.so $INPUT_FLAGS"
output="output_http.so $OUTPUT_FLAGS"
./mjpg_streamer -i "$input" -o "$output"
