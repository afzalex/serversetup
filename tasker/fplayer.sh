#!/bin/bash
# Ref: https://pagaliworld.com/

date "+%s"
SITE_URL="https://pagaliworld.com"
SITE_URL_TO_SEARCH="https://pagaliworld.com/files/search"
SITE_URL_TO_SEARCH_QUERY_KEY="find"
SITE_URL_REQUEST_HEADER_1="user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36"

echo "Source website is \"${SITE_URL}\""

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


# CACHE CHECK
cacheSearchResult=$(cat "${FPLAYER_SEARCHTEXT_CACHEFILE}" | perl -nle "print $& while m{^\d{10}\s{4}${searchText}\$}g" | tail -n1)
if [[ ! -z ${cacheSearchResult} ]]; then 
    echo "Downloaded result found in cache"
    outputFileName=$(echo "${cacheSearchResult}" | perl -nle "print $& while m{^\d{10}(?=\s{4}${searchText}\$)}g")
    outputFile="${FPLAYER_DIR_CACHE}/${outputFileName}"
else 

    FPLAYER_SEARCHRESULT_TEMPFILE="${FPLAYER_DIR_TEMP}/searchtext.dat"
    # SITE QUERY
    siteQueryString="${SITE_URL_TO_SEARCH}?${SITE_URL_TO_SEARCH_QUERY_KEY}=${searchText// /+}"
    echo "Searching ... ${siteQueryString}"
    curl -H "${SITE_URL_REQUEST_HEADER_1}" -s "${siteQueryString}" > "${FPLAYER_SEARCHRESULT_TEMPFILE}" 

    searchResultUrl=$(cat "${FPLAYER_SEARCHRESULT_TEMPFILE}" | 
        tr '\n' ' ' | 
        perl -nle 'print $& while m{<ul.*?</ul>}g' |
        perl -nle 'print $& while m{<li>\s*<a href=.*?<img .*?></a>}g' |
        perl -nle 'print $1 while m{(?<=<a href=")(.*?)"}g' |
        head -n1 )
    if [[ -z "$searchResultUrl" ]]; then
        echo "No result found"
        exit
    fi
    echo $searchResultUrl
    searchResultAbsoluteUrl=${SITE_URL}${searchResultUrl}
    echo $searchResultAbsoluteUrl

    FPLAYER_DOWNLOADPAGE_TEMPFILE="${FPLAYER_DIR_TEMP}/downloadPage.dat"
    echo "Crawling ${searchResultAbsoluteUrl}"
    # CRAWL TO SEARCH DOWNLOAD LINK
    curl -L -H "${SITE_URL_REQUEST_HEADER_1}" -s "$searchResultAbsoluteUrl" > "${FPLAYER_DOWNLOADPAGE_TEMPFILE}"
    
    downloadUrl=$(cat "${FPLAYER_DOWNLOADPAGE_TEMPFILE}" |
        tr '\n' ' ' |
        perl -nle 'print $& while m{<div class="dbutton">.*?320Kbps Mp3 Songs.*?</a>}g' |
        perl -nle 'print $1 while m{<a .*?href="(.*?)" }g' |
        tail -n1)
    
    if [[ ! "$downloadUrl" == http* ]]; then
        downloadUrl="${SITE_URL}${downloadUrl}"
    fi

    if [[ "$downloadUrl" == *.html ]]; then
        downloadUrl2=$(echo "${downloadUrl}" | perl -nle 'print $1 if m{https://href\.li/\?(.*)}g')
        if [[ ! -z ${downloadUrl2} ]]; then 
            echo hola; 
        fi
    fi

    # TODO: Incomplete part to execute when result not found
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

    wget --header="${SITE_URL_REQUEST_HEADER_1}" -O "${outputFile}" "${downloadUrl}"
    echo "${outputFileName}    ${searchText}" >> "${FPLAYER_SEARCHTEXT_CACHEFILE}"
fi

echo "Playing song from file \"${outputFile}\""
FPLAYER_PROCESS_FILE="${FPLAYER_DIR_TEMP}/fplayer_process"

ffplay -nodisp -autoexit "${outputFile}" 


