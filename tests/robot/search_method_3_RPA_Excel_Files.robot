*** Settings ***
Documentation       Search coverage for OWASP Juice Shop using RPA.Excel.Files.
...                 Search method 3: RPA.Excel.Files.
...                 It reads the workbook into memory and iterates through the rows, within one browser session.

Library             Collections
Library             RPA.Excel.Files
Resource            ${CURDIR}/../resources/juice_shop.resource

Test Setup          Open Shop Homepage
Test Teardown       Handle Test Cleanup


*** Variables ***
${SEARCH_EXCEL_FILE}        ${CURDIR}/../data/search_keywords.xlsx
${SEARCH_WORKSHEET_NAME}    SearchCases


*** Test Cases ***
Search Keywords From Excel With RPA Excel Files
    [Documentation]    Verify that every workbook row produces the expected result.
    Search Every Excel Row


*** Keywords ***
Search Every Excel Row
    ${rows}=    Load Search Rows From Excel
    FOR    ${row}    IN    @{rows}
        ${input}=    Get From Dictionary    ${row}    Input
        ${normalized_input}=    Normalize Search Input    ${input}
        ${expectation}=    Get From Dictionary    ${row}    Expectation
        Run Keyword And Continue On Failure    Search Results Should Match    ${normalized_input}    ${expectation}
    END

Load Search Rows From Excel
    Open Workbook    ${SEARCH_EXCEL_FILE}
    ${rows}=    Read Worksheet    name=${SEARCH_WORKSHEET_NAME}    header=${TRUE}
    Close Workbook
    RETURN    ${rows}

Normalize Search Input
    [Arguments]    ${value}
    IF    $value is None    RETURN    ${EMPTY}
    RETURN    ${value}
