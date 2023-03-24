#!/bin/bash

################################################################################
#                                                                              #
# This script was created to run tests on files in different fodlers           #
# with the sudoku program.                                                     #
#                                                                              #
# Folders:                                                                     #
#   - sucess: tests in this folder should result in "SUCESS"                   #
#   - fail: tests in this folder should result in "FAIL"                       #
#   - format: tests in this folder should not generate an output file          #
#                                                                              #
# Unstructions for use:                                                        #
#   1. Make sure the script is in the same folder as the "login" folder        # 
#   2. Change the your_folder variable to your "login"                         #
#   3. Run this script in shell: "./script.sh"                                 #
#   4. The script will execute the sudoku program on each .txt file in         #
#      the folders and will check if the output matches                        #
#   5. If errors occur, a file named "error" will be created in the main       #
#      folder, listing the problematic files                                   #
#   6. Grant permission: chmod 777 h3ndr1.sh                                   #
#                                                                              #
################################################################################

#!/bin/bash

circle_animation() {
    for i in {1..32}; do
        tput setaf 2
        tput cup 1 $((i % 32))
        printf "%s" "Hi Hendrich"
        sleep 0.05
        printf "\r%s" "$(tput el)"
    done
    tput sgr0
}

animation() {
    spin='-\|/'
    for i in {1..8}; do
        printf "\r[${spin:i%4:1}] "
        tput setaf 10
        printf "$1"
        sleep 0.025
    done
    printf "\r%s\r" "$(tput el)"
    tput sgr0
}

circle_animation
your_folder="aham"
main_folder=$(pwd)

cd $your_folder
make > /dev/null 2>&1

folders=("sucess" "fail" "format")

if [ -f "$main_folder/error" ]; then
    rm "$main_folder/error"
fi

declare -A folder_errors

for folder in "${folders[@]}"; do
    tput setaf 5
    printf "Processing folder: "
    tput setaf 7
    printf "$folder "
    tput sgr0

    folder_error=false

    for file in "../$folder"/*; do
        animation "Processing: $(basename "$file")"

        if [ "$folder" == "format" ]; then
            ./sudoku "$file" > "sudoku_format.out"
            if grep -q "File out of format" "sudoku_format.out"; then
                continue
            else
                echo "Error in $(basename "$file")" >> "$main_folder/error"
                folder_errors["$folder"]+="$(basename "$file")"$'\n'
                folder_error=true
            fi
        else
            ./sudoku "$file" > "sudoku_${your_folder}.out"
            output=$(cat "sudoku_${your_folder}.out")

            if [ "$folder" == "sucess" ] && [ "$output" != "SUCESS" ]; then
                echo "Error in $(basename "$file")" >> "$main_folder/error"
                folder_errors["$folder"]+="$(basename "$file")"$'\n'
                folder_error=true
            elif [ "$folder" == "fail" ] && [ "$output" != "FAIL" ]; then
                echo "Error in $(basename "$file")" >> "$main_folder/error"
                folder_errors["$folder"]+="$(basename "$file")"$'\n'
                folder_error=true
            fi

            rm "sudoku_${your_folder}.out"
        fi
    done

    if [ "$folder_error" = true ]; then
        printf "\033[0;34m%s:\033[0m " "Processed $folder" # Dark blue
        tput setaf 1
        printf "✘\n"
        tput sgr0
    else
        printf "\033[0;34m%s:\033[0m " "Processed $folder"
        tput setaf 2
        printf "✔\n"
        tput sgr0
    fi
done

cd "$main_folder"

errors_found=false

for folder in "${folders[@]}"; do
    if [ -n "${folder_errors["$folder"]}" ]; then
        errors_found=true
        echo "Pasta $folder:"
        echo "${folder_errors["$folder"]}"
    fi
done

if [ "$errors_found" = false ]; then
    tput setaf 2
    printf "\n "
    tput setaf 10
    printf "All tests passed!\n"
    tput sgr0
fi
