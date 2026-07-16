*** Settings ***
Documentation       Search coverage for OWASP Juice Shop using Robot Framework DataDriver.
...                 Search method 1: Robot Framework DataDriver.
...                 DataDriver creates one test per row and starts a fresh browser session for each generated test.

Library             DataDriver
...                     file=${CURDIR}/../data/search_keywords_datadriver.csv
...                     dialect=excel
...                     encoding=utf_8
Resource            ${CURDIR}/../resources/juice_shop.resource

Test Setup          Open Shop Homepage
Test Teardown       Handle Test Cleanup
Test Template       Search Row Should Match


*** Test Cases ***
Search for "${keyword}" should return ${amount_of_results} results
    keyword    results


*** Keywords ***
Search Row Should Match
    [Arguments]    ${keyword}
    ...    ${amount_of_results}
    Search Results Should Match    ${keyword}    ${amount_of_results}
