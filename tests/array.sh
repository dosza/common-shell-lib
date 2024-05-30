#!/bin/bash

source ./get-shunit2
testIsArrayEmpty(){
    local array=()
    local fake_array=''
    local fake_array_2=0
    
    isArrayEmpty array 
    assertTrue '[passing an empty array ]' $?

    array=({0..10})
    
    isArrayEmpty array 
    assertFalse '[passing a non-empty array]' $?
    
    local -n ref_array=array

    assertTrue '[Deferencing an array is not supported]' $?
    unset array 

    isArrayEmpty array 
    assertTrue '[No existent array]'  $?

    isArrayEmpty fake_array_2
    assertTrue '[ Case string variable ]' $?


}
testArrayToSTring(){
    local array=({0..10..2})
    local str="0 2 4 6 8 10"
    assertEquals  "$str" "$(arrayToString array)" 
}

testArraySlice(){
    local array=({0..10..2})
    local subarray=()

    arraySlice array 0 5 subarray
    assertEquals  "0 2 4 6 8" "${subarray[*]}" 

    arraySlice array 2 subarray
    assertEquals  "4 6 8 10" "${subarray[*]}" 
    
    array=("make -j3" "bzImage" "make modules" "make install")
    arraySlice array  0 2 subarray
    assertEquals "${subarray[0]}" "make -j3" && assertEquals "${subarray[1]}" "bzImage"
    assertFalse "[ $(arraySlice myarray 0 2 mysubarray) ]"
    assertFalse "[ $(arraySlice myarray) ]"
}

testArrayMap(){
    local empty_array=()
    local packages=(gcc g++ wget)
    local str="gcc\ng++\nwget\n"
    local buttons=(button{Um,Dois,Tres})
    local sounds=(one two three)
    local strButtons='view.findViewById(R.id.buttonUm)\nview.findViewById(R.id.buttonDois)\nview.findViewById(R.id.buttonTres)\n'
    local strButtonsAct="case R.id.${buttons[0]}:\n\tmediaPlayer = MediaPlayer(getActivity(),R.raw.${sounds[0]});\n\tbreak;\ncase R.id.${buttons[1]}:\n\tmediaPlayer = MediaPlayer(getActivity(),R.raw.${sounds[1]});\n\tbreak;\ncase R.id.${buttons[2]}:\n\tmediaPlayer = MediaPlayer(getActivity(),R.raw.${sounds[2]});\n\tbreak;\n"
    assertEquals "$(arrayMap packages package 'echo $package')" "$(printf "%b" "$str")"
    assertEquals "$(arrayMap buttons button index 'echo view.findViewById\(R.id.$button\)')" "$(printf "%b" "$strButtons")"
    assertEquals "$(arrayMap buttons button index 'printf "%b" "case R.id.$button:\n\tmediaPlayer = MediaPlayer(getActivity(),R.raw.${sounds[$index]});\n\tbreak;\n"')" "$(printf "%b" "$strButtonsAct")"

    arrayMap empty_array value 'echo $value'
    assertFalse '[ passing an empty array ]' $?
}

testArrayFilter(){
    local numbers=({357..368})
    local pares=()
    local impares=()
    local names=('Daniel' 'Davros' 'Elis' 'Etel')
    local matchDNames=()

    arrayFilter pares index numbers '((number %2 == 0))'
    assertFalse '[Passing an empty array]' $?

    arrayFilter numbers number pares '((number % 2 == 0))'

    assertEquals "358 360 362 364 366 368" "${pares[*]}" 

    arrayFilter numbers number impares '{
        ((number %2 != 0))
    }'

    assertEquals  "357 359 361 363 365 367" "${impares[*]}" 

    arrayFilter  names name matchDNames 'echo "$name" | grep ^D>/dev/null'
   
    assertEquals  "Daniel Davros" "${matchDNames[*]}"

    arrayFilter  names name index matchDNames 'echo ${names[$index]} | grep ^D>/dev/null'
    assertEquals  "Daniel Davros" "${matchDNames[*]}"

    
}


testForEach(){
    local expected_array_numbers=({3..100..5})
    local array_numbers=({2..100..5})

    local expected_five_table=({0..50..5})
    local five_table=({0..10})

    local empty_array=()

    forEach empty_array value '((value+=1))'
    assertFalse '[passing an empty array]' $?

    forEach five_table number 'number=$(echo "$number * 5"| bc )'

    assertEquals "${expected_five_table[*]}" "${five_table[*]}"

    inc(){
        local current_number=$1
        ((current_number++))
        echo $current_number
    }


    forEach array_numbers number 'number=$(inc $number)'
    assertEquals '[Running forEach without index declaration]'\
        "${expected_array_numbers[*]}" "${array_numbers[*]}"

    array_numbers=({2..100..5})
    #Note: number is reference to array_numbers[$index]
    printf "\t${NEGRITO}"
    forEach array_numbers number index '
        printf "%s " "[$index]"
        number=$(inc $number)'
    echo "${NORMAL}"
    assertEquals '[Running forEach with  index declaration]'\
        "${expected_array_numbers[*]}" "${array_numbers[*]}"
}


testInitArrayAsCommand(){
    local files=`echo *`
    local array_command=()
    initArrayAsCommand array_command 'echo *'
    assertEquals "${files}" "${array_command[*]}"
}
. $(which shunit2)

