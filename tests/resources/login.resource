*** Settings ***
Documentation       Reusable registration, login, and authenticated-state interactions.

Library             DateTime
Library             Browser
Resource            juice_shop.resource


*** Variables ***
${ACCOUNT_BUTTON_LOCATOR}                   css=#navbarAccount
${LOGIN_BUTTON_LOCATOR}                     css=#navbarLoginButton
${LOGOUT_BUTTON_LOCATOR}                    css=#navbarLogoutButton
${EMAIL_INPUT_LOCATOR}                      css=#email
${PASSWORD_INPUT_LOCATOR}                   css=#password
${SUBMIT_LOGIN_LOCATOR}                     css=#loginButton
${LOGIN_ERROR_LOCATOR}                      text=Invalid email or password.
${REGISTER_LINK_LOCATOR}                    css=a[href*="register"]
${REGISTER_EMAIL_INPUT_LOCATOR}             css=#emailControl
${REGISTER_PASSWORD_INPUT_LOCATOR}          css=#passwordControl
${REGISTER_REPEAT_PASSWORD_LOCATOR}         css=#repeatPasswordControl
${REGISTER_SECURITY_QUESTION_LOCATOR}       css=#mat-select-1
${REGISTER_SECURITY_OPTION_LOCATOR}         css=[role="option"] >> nth=0
${REGISTER_SECURITY_ANSWER_LOCATOR}         css=#securityAnswerControl
${REGISTER_SUBMIT_LOCATOR}                  css=#registerButton
${REGISTER_SUCCESS_LOCATOR}                 text=Registration completed successfully. You can now log in.
${REGISTER_SECURITY_ANSWER}                 robot-answer
${ACCOUNT_PREFIX}                           testaccount
${ACCOUNT_DOMAIN}                           teqs-consulting.com
${DEFAULT_ACCOUNT_PASSWORD}                 SecretPassword!
${INVALID_ACCOUNT_PASSWORD}                 WrongSecretPassword!
${INVALID_ACCOUNT_PREFIX}                   invalid-


*** Keywords ***
Create Generated Account
    [Documentation]    Generate credentials, register the account, verify success, and return the email address.
    ${email}    ${password}=    Generate Account Credentials
    Open Registration Page
    Fill Registration Form    ${email}    ${password}
    Submit Registration
    Registration Should Complete Successfully
    RETURN    ${email}

Login With Generated Account
    [Documentation]    Log in with the provided account credentials and then sign back out.
    [Arguments]    ${email}
    ...    ${password}
    Open Login Page
    Submit Login Credentials    ${email}    ${password}
    Successful Login Should Be Visible
    Logout If Signed In

Login With Wrong Password Should Fail
    [Documentation]    Verify that the provided account rejects the configured invalid password.
    [Arguments]    ${email}
    Open Login Page
    Submit Login Credentials    ${email}    ${INVALID_ACCOUNT_PASSWORD}
    Failed Login Should Be Visible
    Account Menu Should Show Logged Out State

Login With Wrong Username Should Fail
    [Documentation]    Verify that the provided account rejects a modified invalid email address.
    [Arguments]    ${email}
    ...    ${password}
    VAR    ${wrong_email}=    ${INVALID_ACCOUNT_PREFIX}${email}
    Open Login Page
    Submit Login Credentials    ${wrong_email}    ${password}
    Failed Login Should Be Visible
    Account Menu Should Show Logged Out State

Generate Account Credentials
    [Documentation]    Generate fresh account credentials for the login flow and return them.
    ${timestamp}=    Get Current Date    result_format=%H%M%S
    VAR    ${email}=    ${ACCOUNT_PREFIX}${timestamp}@${ACCOUNT_DOMAIN}
    RETURN    ${email}    ${DEFAULT_ACCOUNT_PASSWORD}

Open Login Page
    [Documentation]    Open the login form from the account menu and wait for the email field.
    Ensure Account Menu Is Open
    Click    ${LOGIN_BUTTON_LOCATOR}
    Wait For Elements State    ${EMAIL_INPUT_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Open Registration Page
    [Documentation]    Open the registration form from the login dialog.
    Open Login Page
    Click    ${REGISTER_LINK_LOCATOR}
    Wait For Elements State    ${REGISTER_EMAIL_INPUT_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Fill Registration Form
    [Documentation]    Fill the registration form fields with the provided email and password.
    [Arguments]    ${email}
    ...    ${password}
    Fill Text    ${REGISTER_EMAIL_INPUT_LOCATOR}    ${email}
    Fill Text    ${REGISTER_PASSWORD_INPUT_LOCATOR}    ${password}
    Fill Text    ${REGISTER_REPEAT_PASSWORD_LOCATOR}    ${password}
    Click With Options    ${REGISTER_SECURITY_QUESTION_LOCATOR}    force=True
    Wait For Elements State    ${REGISTER_SECURITY_OPTION_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Click With Options    ${REGISTER_SECURITY_OPTION_LOCATOR}    force=True
    Fill Text    ${REGISTER_SECURITY_ANSWER_LOCATOR}    ${REGISTER_SECURITY_ANSWER}

Submit Registration
    [Documentation]    Submit the completed registration form.
    Click    ${REGISTER_SUBMIT_LOCATOR}

Registration Should Complete Successfully
    [Documentation]    Wait until the registration success message is visible.
    Wait For Elements State    ${REGISTER_SUCCESS_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Submit Login Credentials
    [Documentation]    Fill the login form with the provided credentials and submit it.
    [Arguments]    ${email}
    ...    ${password}
    Fill Text    ${EMAIL_INPUT_LOCATOR}    ${email}
    Fill Text    ${PASSWORD_INPUT_LOCATOR}    ${password}
    Click    ${SUBMIT_LOGIN_LOCATOR}

Successful Login Should Be Visible
    [Documentation]    Retry until the account menu reflects a logged-in state.
    Wait Until Keyword Succeeds    10x    300ms    Account Menu Should Show Logged In State

Failed Login Should Be Visible
    [Documentation]    Wait until the invalid-credentials message is visible.
    Wait For Elements State    ${LOGIN_ERROR_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Logout If Signed In
    [Documentation]    Log out when the account menu shows an authenticated session.
    Ensure Account Menu Is Open
    ${logout_count}=    Get Element Count    ${LOGOUT_BUTTON_LOCATOR}
    IF    ${logout_count} > 0
        Click    ${LOGOUT_BUTTON_LOCATOR}
        Wait Until Keyword Succeeds    10x    300ms    Account Menu Should Show Logged Out State
    END

Account Menu Should Show Logged In State
    [Documentation]    Verify that the account menu exposes the logout action.
    Ensure Account Menu Is Open
    ${logout_count}=    Get Element Count    ${LOGOUT_BUTTON_LOCATOR}
    Should Be True    ${logout_count} > 0

Account Menu Should Show Logged Out State
    [Documentation]    Verify that the account menu exposes login and hides logout.
    Ensure Account Menu Is Open
    ${login_count}=    Get Element Count    ${LOGIN_BUTTON_LOCATOR}
    ${logout_count}=    Get Element Count    ${LOGOUT_BUTTON_LOCATOR}
    Should Be True    ${login_count} > 0
    Should Be Equal As Integers    ${logout_count}    0

Ensure Account Menu Is Open
    [Documentation]    Open the account menu when its login and logout actions are not yet visible.
    ${login_count}=    Get Element Count    ${LOGIN_BUTTON_LOCATOR}
    ${logout_count}=    Get Element Count    ${LOGOUT_BUTTON_LOCATOR}
    IF    $login_count == 0 and $logout_count == 0
        Click    ${ACCOUNT_BUTTON_LOCATOR}
        Wait Until Keyword Succeeds    10x    300ms    Account Menu Should Contain Actions
    END

Account Menu Should Contain Actions
    [Documentation]    Verify that the account menu shows either login or logout actions.
    ${login_count}=    Get Element Count    ${LOGIN_BUTTON_LOCATOR}
    ${logout_count}=    Get Element Count    ${LOGOUT_BUTTON_LOCATOR}
    Should Be True    ${login_count} > 0 or ${logout_count} > 0
