#!/bin/bash
# Ref: https://pagalnew.com/search.php

SITE_URL=https://pagalnew.com
FPLAYER_DIR="${HOME}/.fplayer"

FPLAYER_DIR_TEMP="${FPLAYER_DIR}/temp"
mkdir -p "${FPLAYER_DIR_TEMP}"
FPLAYER_DIR_CACHE="${FPLAYER_DIR}/cache"
mkdir -p "${FPLAYER_DIR_CACHE}"

if [[ -z "$1" ]]; then
    read -p "Search Query: " searchText
else 
    searchText="$1"
fi
echo "Search Text is ${searchText}"

FPLAYER_SEARCHTEXT_CACHEFILE="${FPLAYER_DIR_CACHE}/searchTextCacheFile.txt"
cacheSearchResult=$(cat "${FPLAYER_SEARCHTEXT_CACHEFILE}" | grep -P "(?<=^\d{19}\s{4})${searchText}\$")
if [[ ! -z ${cacheSearchResult} ]]; then 
    echo "Downloaded result found in cache"
    outputFileName=$(echo "${cacheSearchResult}" | grep -oP '^\d{19}')
    outputFile="${FPLAYER_DIR_CACHE}/${outputFileName}"
else 

    FPLAYER_SEARCHRESULT_TEMPFILE="${FPLAYER_DIR_TEMP}/searchtext.dat"
    echo "Searching ..."
    curl -s "${SITE_URL}/search.php?find=${searchText// /+}" > "${FPLAYER_SEARCHRESULT_TEMPFILE}" 
    searchResultUrl=$(cat "${FPLAYER_SEARCHRESULT_TEMPFILE}" | grep -Pazo '(?s)Result.*href=".*?\>' | grep -Pao '(?<=href=").*\.html' | head -n1 ) 
    if [[ -z "$searchResultUrl" ]]; then
        echo "No result found"
        exit
    fi
    searchResultAbsoluteUrl=${SITE_URL}${searchResultUrl}

    FPLAYER_DOWNLOADPAGE_TEMPFILE="${FPLAYER_DIR_TEMP}/downloadPage.dat"
    echo "Crawling ${searchResultAbsoluteUrl}"
    curl -s "$searchResultAbsoluteUrl" > "${FPLAYER_DOWNLOADPAGE_TEMPFILE}"
    downloadUrl=$(cat "${FPLAYER_DOWNLOADPAGE_TEMPFILE}" | grep -Pazo '\<.*?320 KBPS Song Download.*?\>' | grep -Pao '(?<=href\=").*(?="\>)' | tr -d '\0')

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


    outputFileName=$(date "+%s%N")

    outputFile="${FPLAYER_DIR_CACHE}/${outputFileName}"
    echo "Downloading result from ${downloadUrl} to ${outputFile}"
    wget -q -O "${outputFile}" "${downloadUrl}"

    echo "${outputFileName}    ${searchText}" >> "${FPLAYER_SEARCHTEXT_CACHEFILE}"
fi

echo "Playing song from file ${outputFile}"
FPLAYER_PROCESS_FILE="${FPLAYER_DIR_TEMP}/fplayer_process"

# echo ffplay -nodisp -autoexit  "${outputFile}" > ${FPLAYER_PROCESS_FILE}
# chmod +x "${FPLAYER_PROCESS_FILE}"

# exec "${FPLAYER_PROCESS_FILE}"

ffplay -nodisp -autoexit -v 8  "${outputFile}" 
