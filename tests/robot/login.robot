*** Settings ***
Documentation       Login coverage for OWASP Juice Shop.

Resource            ../resources/login.resource

Test Setup          Open Shop Homepage
Test Teardown       Handle Test Cleanup


*** Test Cases ***
Create Account
    [Documentation]    Create a fresh timestamped account for the login flow.
    Create Generated Account

Login With Created Account
    [Documentation]    Log in with a newly created account. Afterwards, log out.
    ${email}=    Create Generated Account
    Login With Generated Account    ${email}    ${DEFAULT_ACCOUNT_PASSWORD}

Login With Wrong Password
    [Documentation]    Verify that the generated account rejects an invalid password.
    ${email}=    Create Generated Account
    Login With Wrong Password Should Fail    ${email}

Login With Wrong Username
    [Documentation]    Verify that the generated account rejects an invalid username.
    ${email}=    Create Generated Account
    Login With Wrong Username Should Fail    ${email}    ${DEFAULT_ACCOUNT_PASSWORD}
