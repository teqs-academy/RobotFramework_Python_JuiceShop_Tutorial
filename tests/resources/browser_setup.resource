*** Settings ***
Documentation       Browser lifecycle and failure-artifact helpers for UI suites.

Library             Browser
Resource            ../variables/environment.resource


*** Keywords ***
Open Browser To Shop
    New Browser    ${BROWSER}    headless=${HEADLESS}
    Set Browser Timeout    ${BROWSER_TIMEOUT}

    ${record_video_enabled}=    Convert To Boolean    ${RECORD_VIDEO}

    IF    ${record_video_enabled}
        &{record_video}=    Create Dictionary    dir=${VIDEO_DIR}    size=${VIDEO_SIZE}
        New Context    viewport=${VIEWPORT}    recordVideo=${record_video}
    ELSE
        New Context    viewport=${VIEWPORT}
    END

    New Page    ${BASE_URL}

Close Browser Session
    Run Keyword And Ignore Error    Close Browser

Take Failure Screenshot
    Run Keyword If Test Failed    Take Screenshot

Handle Test Cleanup
    Take Failure Screenshot
    Close Browser Session
