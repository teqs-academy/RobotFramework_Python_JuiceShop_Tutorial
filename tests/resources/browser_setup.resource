*** Settings ***
Documentation       Browser lifecycle and failure-artifact helpers for UI suites.

Library             Browser
Resource            ../variables/environment.resource


*** Keywords ***
Open Browser To Shop
    [Documentation]    Open a browser and page for the configured shop URL with the suite defaults.
    New Browser    ${BROWSER}    headless=${HEADLESS}
    Set Browser Timeout    ${BROWSER_TIMEOUT}

    ${record_video_enabled}=    Convert To Boolean    ${RECORD_VIDEO}

    IF    ${record_video_enabled}
        VAR    &{record_video}=    dir=${VIDEO_DIR}    size=${VIDEO_SIZE}
        New Context    viewport=${VIEWPORT}    recordVideo=${record_video}
    ELSE
        New Context    viewport=${VIEWPORT}
    END

    New Page    ${BASE_URL}

Close Browser Session
    [Documentation]    Close the active browser session and ignore close errors during cleanup.
    Run Keyword And Ignore Error    Close Browser

Take Failure Screenshot
    [Documentation]    Capture a screenshot only when the current test has failed.
    Run Keyword If Test Failed    Take Screenshot

Handle Test Cleanup
    [Documentation]    Collect failure artifacts and close the browser after each test.
    Take Failure Screenshot
    Close Browser Session
