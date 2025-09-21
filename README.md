# Beta
you have been warned.

This script uses cjxl, fd, and zenity. Make sure they are both installed on your system.


# TO-DO
## bugs
- re running the could overwrite jxl in some case
  - could check raw image value to prevent double copys
    - compare again if it pass the step above but with the output of djxl ¹
## Features
- kdialog support
- deletes orignal image
  - if use accepts in zenity menu 
- compares image sum value
  - jpeg uses djxl to compares md5 sum of orginal jpg and out of djxl ¹
    - deletes jxl if it does match
  - webp, png use identify ¹
    - deletes jxl if it does match
- report to user if a image value does match and if cjxl wasn't able to out a image
- finds smallest file footprint best off of effort for each files
  - also support user input effort with zenity

1. some times cjxl output improves the image so the raw image value changes. this does also happen with other image encoders so might need to look into it.
