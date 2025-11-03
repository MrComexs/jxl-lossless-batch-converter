#!/bin/bash
for cmd in zenity cjxl djxl jxlinfo fd echo sed mkdir mktemp mv identify; do
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

effort=$(zenity --entry --text "What effort would you like? \n \n The Higher the number the more effort cjxl spends \n \n 7 is the default for cjxl" --entry-text "1-10" --title "Enter Effort")

if [[ $effort =~ ^[1-9]$|^10$ ]]; then
    :
    #zenity --info --text="You entered: $effort"
else
    zenity --error --text="Invalid input. Please enter a number between 1 and 10."
    exit 1
fi

if zenity --question --text "Is this the Corrent effort and path? \n \n Effort: $effort \n $selected_dir" --title "Confirmation"; then
    echo
else
    zenity --info --text "script terminated"
    exit 1
fi

cd "$selected_dir"||exit 1
clear

output_dir="${selected_dir}/converted_jxl"

if [ ! -d "$output_dir" ]; then
    mkdir "$output_dir"
 fi

temp_dir=$(mktemp -d)

fd -e jpg -e jpeg -e png | while IFS= read -r file; do

    input_size=$(stat -c "%s" "$file")

    file_type=$(identify -format "%m" "$file")

    if [ "$file_type" == JPEG ]; then
        jpeg_cjxl_arg="-j 1"
        #echo "$file is a JPEG"
    elif [ "$file_type" == PNG ]; then
        #echo "$file is a PNG"
        :
    else 
        echo "$file isn't either a JPEG, or PNG. exiting"
        exit 1
    fi
    
    base_name="${file##*/}"
    no_extension="${base_name%.*}"
    file_path="${file%/*}"

    if [[ "$file_path" == "$base_name" ]]; then
        sub_output_dir=""
    else
        sub_output_dir="$(echo "$file_path" | sed "s|$selected_dir||")"       
    fi

    if [ ! -d "$output_dir/$sub_output_dir" ]; then
    mkdir -p "$output_dir/$sub_output_dir"    
    fi

    temp_output_jxl="$temp_dir/${no_extension}.jxl"
    output_jxl="$output_dir/$sub_output_dir/${no_extension}.jxl"
    output_ext_jxl="$output_dir/$sub_output_dir/${base_name}.jxl"
    # either check if $output_dir exist than exit or fix below

    cjxl "$file" -e "$effort" -d 0 $jpeg_cjxl_arg --quiet "$temp_output_jxl"

    # Checks if "JPEG bitstream reconstruction data available" was outputed from the old jxl file
    if [ -f "$output_jxl" ]; then
        jxlinfo_output=$(jxlinfo "$output_jxl")
            if echo "$jxlinfo_output" | grep -q "JPEG bitstream reconstruction data available"; then
                djxl "$output_jxl" "$temp_dir/${no_extension}.jpg"
                djxl_output_value=$(identify -format "%#\n" "$temp_dir/${no_extension}.jpg")
                rm "$temp_dir/${no_extension}.jpg"
            fi
    fi
    input_value=$(identify -format "%#\n" "$file")
    temp_output_value=$(identify -format "%#\n" "$temp_output_jxl")
    if [ -f "$output_jxl" ]; then
        old_output_value=$(identify -format "%#\n" "$output_jxl")
    fi
     
    if [ ! -f "$output_jxl" ]; then
        mv "$temp_output_jxl" "$output_jxl"
        output_size=$(stat -c "%s" "$output_jxl")
        if [[ $output_size -gt $input_size ]]; then
            rm "$output_jxl"  # Delete output file if it's larger
            echo "Deleted $output_ext_jxl since it was bigger than the original"
        fi
    elif [ "$input_value" == "$old_output_value" ]; then
        rm "$temp_output_jxl"
        echo "$file old jxl match, not writing"
    elif [ "$temp_output_value" == "$old_output_value" ]; then
        rm "$temp_output_jxl"
        echo "$file cjxl output match with old jxl"
    elif [ "$input_value" == "$djxl_output_value" ]; then
        rm "$temp_output_jxl"
        echo "$file djxl value matched"
    elif [ ! -f "$output_ext_jxl" ];then
        mv "$temp_output_jxl" "$output_ext_jxl"
        output_size=$(stat -c "%s" "$temp_output_jxl" "$output_ext_jxl")
        if [[ $output_size -gt $input_size ]]; then
            rm "$output_ext_jxl"  # Delete output file if it's larger
            echo "Deleted $output_ext_jxl since it was bigger than the original"
        fi
    else
        zenity --error --text="$file couldn't be written \n  \n${no_extension}.jxl and ${file}.jxl already exist"
        rm "$temp_output_jxl"
    fi
echo

done

rmdir "$temp_dir"
rm -d "$output_dir" 2>/dev/null
