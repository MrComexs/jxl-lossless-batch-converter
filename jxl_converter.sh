#!/bin/bash
for cmd in zenity cjxl fd echo sed mkdir; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    [[ $cmd == "zenity" ]] || zenity --error --text="Error: $cmd not found. Please install it first."
    exit 1
  fi
done

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

    if [ ! -d "$output_dir/$sub_output_dir" ]; then
    mkdir -p "$output_dir/$sub_output_dir"    
    fi

    output_jxl="$output_dir/$sub_output_dir/${no_extension}.jxl"
    # what if user ran the script again both $output_jxl and water-cats.jpg.jxl exist it would overwrite water-cats each time
    # either check if $output_dir exist than exit or fix below
    if [ -f "$output_jxl" ]; then
        cjxl "$file" -e 1 -d 0 "$output_dir/$sub_output_dir/${base_name}.jxl"
    else
        cjxl "$file" -e 1 -d 0 "$output_jxl"
    fi
    echo
    # add zenity prompt to ask user if they want to remove orginal file
    # rm "$file" 
done
