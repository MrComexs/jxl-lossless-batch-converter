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

effort=$(zenity --entry --text "What effort would you like? \n \n The Higher the number the more effort cjxl spends \n \n 7 is the default for cjxl" --entry-text "1-10" --title "Enter Effort")

if [[ $effort =~ ^[1-9]$|^10$ ]]; then
    zenity --info --text="You entered: $effort"
else
    zenity --error --text="Invalid input. Please enter a number between 1 and 10."
fi

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
        cjxl "$file" -e "$effort" -d 0 "$output_dir/$sub_output_dir/${base_name}.jxl"
    else
        cjxl "$file" -e "$effort" -d 0 "$output_jxl"
    fi
    echo
    # add zenity prompt to ask user if they want to remove orginal file
    # rm "$file" 
done
