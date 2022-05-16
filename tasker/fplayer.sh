#!/bin/bash
# Ref: https://pagalnew.com/search.php

SITE_URL=https://pagalnew.com
FPLAYER_DIR="${HOME}/.fplayer"

FPLAYER_DIR_TEMP="${FPLAYER_DIR}/temp"
mkdir -p "${FPLAYER_DIR_TEMP}"
FPLAYER_DIR_CACHE="${FPLAYER_DIR}/cache"
mkdir -p "${FPLAYER_DIR_CACHE}"

COMMAND_NAME=fplayer
if [[ "$1" == "-h" ]]; then
cat <<EOF
${COMMAND_NAME} "<song search query>"            play song
${COMMAND_NAME} "<song search query>" -q         search and exit
${COMMAND_NAME} "<song search query>" -f         search, recreate cache and play song
EOF
exit
fi


if [[ ! -z "$2" ]]; then
    case $2 in
        "-q")
            echo "selected to quit after search"
            ;;
        "-f")
            echo "selected to recreate cache after search"
            ;;
    esac
fi


if [[ -z "$1" ]]; then
    read -p "Search Query: " searchText
else 
    searchText="$1"
fi

echo "Search Text is \"${searchText}\""

FPLAYER_SEARCHTEXT_CACHEFILE="${FPLAYER_DIR_CACHE}/searchTextCacheFile.txt"
touch "${FPLAYER_DIR_CACHE}/searchTextCacheFile.txt"
cacheSearchResult=$(cat "${FPLAYER_SEARCHTEXT_CACHEFILE}" | perl -nle "print $& while m{^\d{10}\s{4}${searchText}\$}g" | tail -n1)
if [[ ! -z ${cacheSearchResult} ]]; then 
    echo "Downloaded result found in cache"
    outputFileName=$(echo "${cacheSearchResult}" | perl -nle "print $& while m{^\d{10}(?=\s{4}${searchText}\$)}g")
    outputFile="${FPLAYER_DIR_CACHE}/${outputFileName}"
else 

    FPLAYER_SEARCHRESULT_TEMPFILE="${FPLAYER_DIR_TEMP}/searchtext.dat"
    echo "Searching ..."
    curl -s "${SITE_URL}/search.php?find=${searchText// /+}" > "${FPLAYER_SEARCHRESULT_TEMPFILE}" 
    searchResultUrl=$(cat "${FPLAYER_SEARCHRESULT_TEMPFILE}" | 
        tr '\n' ' ' | 
        perl -nle 'print $& while m{Result.*}g' | 
        perl -nle 'print $& while m{(?<=<a href=\").*?\.html}g' | 
        head -n1)
    if [[ -z "$searchResultUrl" ]]; then
        echo "No result found"
        exit
    fi
    searchResultAbsoluteUrl=${SITE_URL}${searchResultUrl}

    FPLAYER_DOWNLOADPAGE_TEMPFILE="${FPLAYER_DIR_TEMP}/downloadPage.dat"
    echo "Crawling ${searchResultAbsoluteUrl}"
    curl -s "$searchResultAbsoluteUrl" > "${FPLAYER_DOWNLOADPAGE_TEMPFILE}"
    downloadUrl=$(cat "${FPLAYER_DOWNLOADPAGE_TEMPFILE}" | 
        tr '\n' ' ' | 
        perl -nle 'print $& while m{128 KBPS Song .*?320 KBPS Song Download.*?\>}g' | 
        perl -nle 'print $& while m{(?<=href\=").*(?="\>)}g')

    if [[ -z "$downloadUrl" ]]; then
        echo "Download url not found"
        echo "Searching again in nested page"


        searchResultUrl=$(cat "${FPLAYER_DOWNLOADPAGE_TEMPFILE}" | grep -Pazo '(?s)main_page_category_music.*href=".*?pagination' | grep -Pao '(?<=href\=").*(?="\>)' | head -n1)
        if [[ -z "$searchResultUrl" ]]; then
            echo "No result found in nested page"
            exit
        fi
        echo "Crawling ${searchResultAbsoluteUrl}"
        curl -s "$searchResultAbsoluteUrl" > "${FPLAYER_DOWNLOADPAGE_TEMPFILE}"
        searchResultUrl=$(cat "${FPLAYER_DOWNLOADPAGE_TEMPFILE}" | grep -Pazo '(?s)main_page_category_music.*href=".*?pagination' | grep -Pao '(?<=href\=").*(?="\>)' | head -n1)
        if [[ -z "$searchResultUrl" ]]; then
            echo "No result found in nested page"
            exit
        fi

        searchResultAbsoluteUrl=${searchResultUrl}
        echo "Crawling ${searchResultAbsoluteUrl}"
        curl -s "$searchResultAbsoluteUrl" > "${FPLAYER_DOWNLOADPAGE_TEMPFILE}"
        downloadUrl=$(cat "${FPLAYER_DOWNLOADPAGE_TEMPFILE}" | grep -Pazo '\<.*?320 KBPS Song Download.*?\>' | grep -Pao '(?<=href\=").*(?="\>)' | tr -d '\0')

        if [[ -z "$downloadUrl" ]]; then
            echo "Download url not found in nested page too"
            exit
        fi
    fi


    outputFileName=$(date "+%s")

    outputFile="${FPLAYER_DIR_CACHE}/${outputFileName}"
    echo "Downloading result from ${downloadUrl} to ${outputFile}"
    wget -O "${outputFile}" "${downloadUrl}"

    echo "${outputFileName}    ${searchText}" >> "${FPLAYER_SEARCHTEXT_CACHEFILE}"
fi

echo "Playing song from file \"${outputFile}\""
FPLAYER_PROCESS_FILE="${FPLAYER_DIR_TEMP}/fplayer_process"

# echo ffplay -nodisp -autoexit  "${outputFile}" > ${FPLAYER_PROCESS_FILE}
# chmod +x "${FPLAYER_PROCESS_FILE}"

# exec "${FPLAYER_PROCESS_FILE}"

ffplay -nodisp -autoexit "${outputFile}" 


