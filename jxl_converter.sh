#!/bin/bash
if [ ! -x "$(command -v cjxl)" ]; then
    zenity --error --text="Error: cjxl not found. Please install it first."
    exit 1
fi

#kdialog --getexistingdirectory

if [ ! -x "$(command -v cjxl)" ]; then
    zenity --error --text="Error: cjxl not found. Please install it first."
    exit 1
fi

selected_dir=$(zenity --file-selection --directory)

if [ -z "$selected_dir" ]; then
    exit 1
elif [ ! -d "$selected_dir" ]; then
    zenity --error --text="The selected path is not a directory."
    exit 1
elif [ "$selected_dir" = "$HOME" ]; then
    zenity --error --text="You cannot select your home directory. Please select another directory."
    exit 1
fi
clear

cd "$selected_dir"||exit 1

output_dir="${selected_dir}/converted_jxl"
mkdir "$output_dir"

fd -e jpg -e jpeg -e png | while IFS= read -r file; do
    base_name="${file##*/}"
    no_extension="${base_name%.*}"
    file_path="${file%/*}"

    if [[ "$file_path" == "$base_name" ]]; then
        sub_output_dir="$(echo "$file_path" | sed "s|$base_name||")"
               
    else
         sub_output_dir="$(echo "$file_path" | sed "s|$selected_dir||")"       
    fi

    mkdir -p "$output_dir/$sub_output_dir"    
    cjxl "$file" -e 1 -d 0 "$output_dir/$sub_output_dir/${base_name}.jxl"
    echo
done
