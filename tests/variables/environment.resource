*** Settings ***
Documentation       Shared environment values for local and CI UI test runs.


*** Variables ***
${BASE_URL}                 %{BASE_URL=http://127.0.0.1:3000}
${BROWSER}                  %{BROWSER=chromium}
${HEADLESS}                 %{HEADLESS=True}
${BROWSER_TIMEOUT}          20s
${SEARCH_TERM}              apple
${EXPECTED_CATALOG_TEXT}    OWASP Juice Shop

${RECORD_VIDEO}             %{RECORD_VIDEO=False}
${VIDEO_DIR}                %{VIDEO_DIR=${OUTPUT_DIR}${/}videos}
&{VIEWPORT}                 width=1350    height=675
&{VIDEO_SIZE}               width=1350    height=675
