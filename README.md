# Beta
you have been warned and also there is no warranty for this script.

This script uses libjxl, fd, imagemagick and zenity. Make sure they are both installed on your system.

# Features
- converts jpg and png
- keep folder structure
- asks user for effort and input folder using zenity
- some duplication protection
- deletes jxl if input is smaller
# TO-DO
- speed it up
## bugs
- none that I know of
## Features
- asked user if they want to import images that were smaller then the output of cjxl
- webp support
- kdialog support
- deletes the orignal image
  - if use accepts in zenity menu 
- compares image sum value to make sure that input and jxl_output are lossless
  - jpeg uses djxl to compares md5 sum of orginal jpg and out of djxl ¹
    - deletes jxl if it does match
  - webp, png use identify ¹
    - deletes jxl if it does match
- report to user if a image value does match and if cjxl wasn't able to out a image
- finds smallest file footprint best off of effort for each files
- temp_output_jxl and old_jxl sha256 
- better errors 

1. some times cjxl output improves the image so the raw image value changes. this does also happen with other image encoders so might need to look into it.
