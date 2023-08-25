#!/bin/bash

generate_word_list() {
    local num_words=$1
    local word_type=$2
    local min_length=$3
    local max_length=$4
    local filename=$5

    for ((i=0; i<num_words; i++)); do
        word_length=$((RANDOM % (max_length - min_length + 1) + min_length))
        case $word_type in
            1)
                word=$(cat /dev/urandom | tr -dc '0-9' | fold -w $word_length | head -n 1)
                ;;
            2)
                word=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $word_length | head -n 1)
                ;;
            3)
                word=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()_+{}|:"<>?,./;'\''[]\=-' | fold -w $word_length | head -n 1)
                ;;
        esac
        echo $word >> $filename
    done
}

generate_word_list_custom() {
    local num_words=$1
    local input_string=$2
    local filename=$3

    words=($input_string)
    num_words_input=${#words[@]}

    for ((i=0; i<num_words; i++)); do
        word=${words[i % num_words_input]}
        echo $word >> $filename
    done
}

sudo_check() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script requires root privileges."
        exit 1
    fi
}

sudo_check

read -p "Select operation: (1) Generate based on input categories, (2) Custom input: " operation

case $operation in
    1)
        read -p "Enter categories separated by spaces (e.g., first last nick age): " categories
        input_string=""
        for category in $categories; do
            read -p "Enter $category: " value
            input_string+="$value "
        done
        ;;
    2)
        read -p "Enter custom input separated by spaces: " input_string
        ;;
    *)
        echo "Invalid option selected."
        exit 1
        ;;
esac

read -p "Enter the number of words: " num_words
read -p "Select the type of words: (1) Numbers, (2) Numbers + Characters, (3) Numbers + Characters + Special Characters: " word_type
read -p "Enter the minimum word length: " min_length
read -p "Enter the maximum word length: " max_length
read -p "Enter the output directory: " output_dir
read -p "Enter the filename to save the word list (e.g., words.txt): " filename

output_path="$output_dir/$filename"

if [ $operation -eq 1 ]; then
    generate_word_list_custom $num_words "$input_string" "$output_path"
else
    generate_word_list $num_words $word_type $min_length $max_length "$output_path"
fi

echo "Word list saved to $output_path"

