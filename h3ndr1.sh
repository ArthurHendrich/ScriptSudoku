#!/bin/bash

################################################################################
#                                                                              #
# Este script foi criado para executar testes em arquivos em diferentes        #
# pastas com o programa sudoku.                                                #
#                                                                              #
# Pastas:                                                                      #
#   - sucess: os testes nesta pasta devem resultar em "SUCCESS"                #
#   - fail: os testes nesta pasta devem resultar em "FAIL"                     #
#   - format: os testes nesta pasta não devem gerar um arquivo de saída        #
#                                                                              #
# Instruções de uso:                                                           #
#   1. Certifique-se de que o script está na mesma pasta que a pasta "login"   # 
#   2. Altere a variavel your_folder para o seu login                          #
#   3. Execute este script em shell: `./script.sh`                             #
#   4. O script irá executar o programa sudoku em cada arquivo .txt nas pastas #
#      e verificar se a saída corresponde ao esperado                          #
#   5. Se ocorrerem erros, um arquivo chamado "error" será criado na pasta     #
#      principal, listando os arquivos problemáticos                           #
#   6. Dê permição chmod 777 (h3ndr1ch)                                        #
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
                folder_error=true
            fi
        else
            ./sudoku "$file" > "sudoku_${your_folder}.out"
            output=$(cat "sudoku_${your_folder}.out")

            if [ "$folder" == "sucess" ] && [ "$output" != "SUCCESS" ]; then
                echo "Error in $(basename "$file")" >> "$main_folder/error"
                folder_error=true
            elif [ "$folder" == "fail" ] && [ "$output" != "FAIL" ]; then
                echo "Error in $(basename "$file")" >> "$main_folder/error"
                folder_error=true
            fi

            rm "sudoku_${your_folder}.out"
        fi
    done

    if [ "$folder_error" = true ]; then
        printf "\033[0;34m%s:\033[0m " "Processed $folder" # Azul escuro
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

if [ -f "error" ]; then
    echo "Errors found:"
    cat "error"
else
    tput setaf 2
    printf "\n "
    tput setaf 10
    printf "All tests passed!\n"
    tput sgr0
fi