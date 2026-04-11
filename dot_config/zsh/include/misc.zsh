pcols(){
    for i in {0..7}; do
        echo -e "\e[4${i}mBackground ${i}\e[0m"
    done
}
