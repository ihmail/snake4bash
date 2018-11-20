#!/bin/bash

function lost() {
  tput cup $(( $(tput lines) / 2 )) $(( $(tput cols) / 2 ))
  tput bold
  echo "YOU LOST!"
  sleep 2.5
  menu
}

function menu() {
  border
  banner_c=$(($(tput cols) / 2 - 39 ))
  tput bold
  tput cup 9 $banner_c
  echo '  ______             _              _     _    ______  _______  ______ _     _ '
  tput cup 10 $banner_c
  echo ' / _____)           | |            | |   (_)  (____  \(_______)/ _____|_)   (_)'
  tput cup 11 $banner_c
  echo '( (____  ____  _____| |  _ _____   | |_____    ____)  )_______( (____  _______ '
  tput cup 12 $banner_c
  echo ' \____ \|  _ \(____ | |_/ ) ___ |  |_____  |  |  __  (|  ___  |\____ \|  ___  |'
  tput cup 13 $banner_c
  echo ' _____) ) | | / ___ |  _ (| ____|        | |  | |__)  ) |   | |_____) ) |   | |'
  tput cup 14 $banner_c
  echo '(______/|_| |_\_____|_| \_)_____)        |_|  |______/|_|   |_(______/|_|   |_|'
  tput cup 15 $banner_c
  tput cup $(($(tput lines) / 2 + 5)) $(($(tput cols) / 2 - 7))
  printf "N - New Game"
  tput cup $(($(tput lines) / 2 + 7)) $(($(tput cols) / 2 - 7))
  printf "H - Highscores"
  tput cup $(($(tput lines) / 2 + 9)) $(($(tput cols) / 2 - 7))
  printf "Q - Quit"
  # lines=$(($(tput lines) - 1))
  # cols=$(($(tput cols) - 1))
  # while true; do
  #   # echo $lines
  #   # echo $cols
  #   # tput cup $(shuf -i20-$lines -n1) $(shuf -i2-$cols -n1)
  #   # printf "◘"
  # done
  while true; do
    read -n 1 -t 0.5 opt
    case $opt in
      [nN]) snake ;;
      [hH]) ;;  #Work in progress
      [qQ]) quit ;;
      *) ;;
    esac
  done
  }

function quit() {
  setterm -cursor on
  stty echo
  tput sgr0
  clear
  exit 0
}

function border() {
  setterm -cursor off
  stty -echo
  clear
  linebrd=$(tput lines)
  colbrd=$(tput cols)
  for line in $(seq 3 "$linebrd"); do
    tput cup $line 1
    printf "|"
    tput cup $line $colbrd
    printf "|"
  done
  for col in $(seq 1 "$colbrd"); do
    tput cup 2 $col
    printf "-"
    tput cup $(($linebrd - 1)) $col
    printf "-"
  done
  # tput cup 1 1
  # printf "Press 'Q' to quit"

}


function snake() {
  clear
  border
  tput cup 1 $(($(tput cols) - 17))
  printf "Press 'Q' to quit"
  escape_char=$(printf "\u1b")

  X=(8 9 10 11 12)  #
  Y=(10 10 10 10 10)  #
  last=$((${#X[*]} - 1))
  point=0
  totalPoints=0
  tput cup 1 1
  #dir_x=2
  printf "Points: %i" "$totalPoints"
  for p in $(seq 0 $last); do
      tput cup ${Y[$p]} ${X[$p]}           #this dumb duck wants its input in YX instead of XY coordinate system
      printf "◘"
  done
  tput cup 10 8
  read -p "Double Tap right arrow to start" -n 1 start
  tput cup 10 8
  echo "                                  "
  while true; do
    if [[ ${X[0]} -le $(tput cols) ]] && [[ ${Y[0]} == 2 ]]; then
      lost
    elif [[ ${X[0]} -le $(tput cols) ]] && [[ ${Y[0]} == $(tput lines) ]]; then
      lost
    fi

    if [[ ${X[0]} == 1 ]] && [[ ${Y[0]} -le $(tput lines) ]]; then
        lost
    elif [[ ${X[0]} == $(tput cols) ]] && [[ ${Y[0]} -le $(tput lines) ]]; then
        lost
    fi

    if [[ ${X[0]} == "$pY" ]] && [[ ${Y[0]} == "$pX" ]]; then
      point=0
      ate=1
      ((totalPoints+=1))
      tput cup 1 1
      echo "Points: $totalPoints"
    fi

    for q in $(seq $last -1 1); do
      if [[ $q == "$last" ]]; then
        X=("${X[@]}" "${X[$q-1]}")
        Y=("${Y[@]}" "${Y[$q-1]}")
      else
        X[$q]=${X[$((q-1))]}
        Y[$q]=${Y[$((q-1))]}
      fi
    done
    #echo 2
    read -rsn1 -t 0.05 direction # get 1 character
    if [[ $direction == "$escape_char" ]]; then
      read -rsn2 direction # read 2 more chars
    elif [[ $direction == "q" ]] || [[ $direction == "Q" ]]; then
      quit
    fi
    #echo 3
    case $direction in
      '[A')   #up
          if [[ $dir != 2 ]]; then
            #X[0]=${X[1]}
            #Y[$first]=$(( Y[$first] - 1 ))
            dir=1
            dir_x=0
            dir_y=-1
          fi
            ;;
      '[B')   #down
          if [[ $dir != 1 ]]; then
            #X[0]=${X[1]}
            #Y[$first]=$(( Y[$first] + 1 ))
            dir=2
            dir_x=0
            dir_y=1
          fi
            ;;
      '[C')   #right
          if [[ $dir != 4 ]]; then
            #X[$first]=$(( X[$first] + 1 ))
            #Y[0]=${Y[1]}
            dir=3
            dir_x=1
            dir_y=0
          fi
            ;;
      '[D')   #left
          if [[ $dir != 3 ]]; then
            #X[$first]=$(( X[$first] - 1 ))
            #Y[0]=${Y[1]}
            dir=4
            dir_x=-1
            dir_y=0
          fi
            ;;
      "")   ;;
       *)   ;;
    esac
    X[0]=$(( X[0] + dir_x))
    Y[0]=$(( Y[0] + dir_y ))

    if [[ $point == 0 ]]; then
      check=1
      while [[ $check == 1 ]]; do
        check=0
        pX=$(shuf -i3-$(($(tput lines) - 1)) -n1)
        for i in "${X[@]}"; do
          if [[ $i == "$pX" ]]; then
            check=1
          fi
        done
      done

      check=1
      while [[ $check == 1 ]]; do
        check=0
        pY=$(shuf -i2-$(($(tput cols) - 1)) -n1)
        #echo $pY
        for i in "${Y[@]}"; do
          if [[ $i == "$pY" ]]; then
            check=1
            #echo $i este $pY
          fi
        done
      done
      tput cup $pX $pY
      printf "◘"
      point=1
    fi



    tput cup ${Y[0]} ${X[0]}
    printf "◘"
    if [[ $ate == 0 ]]; then
      tput cup ${Y[$last]} ${X[$last]}
      printf " "
      unset X[$last]
      unset Y[$last]
    fi
    ate=0
    #echo $last
    #sleep 0.01
    # echo "----------------------" >> test.txt
    # echo X: ${X[*]} >> ./test.txt
    # echo Y: ${Y[*]} >> ./test.txt
    # echo X: ${#X[*]} Y: ${#Y[*]} >> test.txt
  done
}

# function test() {
#   escape_char=$(printf "\u1b")
#   while true; do
#     read -rsn1 mode # get 1 character
#     if [[ $mode == "$escape_char" ]]; then
#         read -rsn2 mode # read 2 more chars
#     fi
#     case $mode in
#         '[A')   #up
#               echo "merge"
#               new_x=0
#               ;;
#             esac
#           done
# }

menu
