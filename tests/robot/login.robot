*** Settings ***
Documentation       Login coverage for OWASP Juice Shop.

Resource            ../resources/login.resource
Resource            ../resources/browser_setup.resource

Test Setup          Open Shop Homepage
Test Teardown       Handle Test Cleanup


*** Test Cases ***
Create Account
    [Documentation]    Create a fresh timestamped account for the login flow.
    Create Generated Account

Login With Created Account
    [Documentation]    Log in with the account created by the prior test.
    Login With Generated Account

Login With Wrong Password
    [Documentation]    Verify that the generated account rejects an invalid password.
    Login With Wrong Password Should Fail

Login With Wrong Username
    [Documentation]    Verify that the generated account rejects an invalid username.
    Login With Wrong Username Should Fail
