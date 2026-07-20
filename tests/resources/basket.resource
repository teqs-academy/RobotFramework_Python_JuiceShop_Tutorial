*** Settings ***
Documentation       Reusable basket UI actions and assertions for the Juice Shop demo.

Library             String
Resource            juice_shop.resource
Resource            login.resource


*** Variables ***
${FIRST_BASKET_ITEM_NAME_LOCATOR}           css=mat-row >> nth=0 >> css=.cdk-column-product
${FIRST_BASKET_ITEM_QUANTITY_LOCATOR}       css=mat-row >> nth=0 >> css=.cdk-column-quantity span.cell-initial-font
${FIRST_BASKET_ITEM_PRICE_LOCATOR}          css=mat-row >> nth=0 >> css=.cdk-column-price
${FIRST_BASKET_ITEM_PLUS_BUTTON_LOCATOR}    css=mat-row >> nth=0 >> css=.cdk-column-quantity button >> nth=1
${BASKET_SNACKBAR_CLOSE_LOCATOR}            css=mat-snack-bar-container button:has-text("X"),
...                                         simple-snack-bar button:has-text("X")


*** Keywords ***
Add First Visible Product To Basket Multiple Times
    [Documentation]    Add the first visible catalog product to the basket the requested number of times.
    [Arguments]    ${count}
    ${times}=    Convert To Integer    ${count}
    FOR    ${_}    IN RANGE    ${times}
        Add First Visible Product To Basket
        Close Basket Snackbar If Present
    END

Basket Title Should Show Owner
    [Documentation]    Verify that the basket page title includes the expected owner label.
    [Arguments]    ${owner_text}
    ${title}=    Get Text    ${BASKET_PAGE_TITLE_LOCATOR}
    Should Contain    ${title}    ${owner_text}

Basket Should Be Empty
    [Documentation]    Verify that the basket shows no rows, no count, and no total price.
    Basket Page Should Be Visible
    ${rows}=    Get Element Count    ${BASKET_ITEM_ROW_LOCATOR}
    Should Be Equal As Integers    ${rows}    0
    Basket Count Should Be    0
    Basket Total Price Should Be In Cents    0

Basket Page Should Be Visible
    [Documentation]    Wait until the basket page header and total price are both visible.
    Wait For Elements State    ${BASKET_PAGE_TITLE_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Wait For Elements State    ${BASKET_TOTAL_PRICE_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Basket Count Should Be
    [Documentation]    Retry until the basket counter matches the expected quantity.
    [Arguments]    ${expected_count}
    Wait Until Keyword Succeeds    10x    300ms    Basket Count Should Be Exactly    ${expected_count}

Basket Count Should Be Exactly
    [Documentation]    Verify that the basket counter exactly matches the expected quantity.
    [Arguments]    ${expected_count}
    ${actual_count}=    Read Basket Count
    Should Be Equal As Integers    ${actual_count}    ${expected_count}

Basket Should Show Product Quantity
    [Documentation]    Retry until the first basket row shows the expected product quantity.
    [Arguments]    ${expected_quantity}
    Wait Until Keyword Succeeds    10x    300ms    Basket Quantity Should Be Exactly    ${expected_quantity}

Basket Quantity Should Be Exactly
    [Documentation]    Verify that the first basket row shows the expected product quantity.
    [Arguments]    ${expected_quantity}
    ${actual_quantity}=    Read First Basket Item Quantity
    Should Be Equal As Integers    ${actual_quantity}    ${expected_quantity}

Basket Total Price Should Match Visible Item Price
    [Documentation]    Verify that the basket total equals the visible item quantity multiplied by its unit price.
    ${quantity}=    Read First Basket Item Quantity
    ${unit_price}=    Read First Basket Item Price In Cents
    ${expected_total}=    Evaluate    int($quantity) * int($unit_price)
    Basket Total Price Should Be In Cents    ${expected_total}

Basket Total Price Should Be In Cents
    [Documentation]    Retry until the basket total matches the expected value in cents.
    [Arguments]    ${expected_total}
    Wait Until Keyword Succeeds    10x    300ms    Basket Total Price Should Be Exactly In Cents    ${expected_total}

Basket Total Price Should Be Exactly In Cents
    [Documentation]    Verify that the basket total exactly matches the expected value in cents.
    [Arguments]    ${expected_total}
    ${actual_total}=    Read Basket Total Price In Cents
    Should Be Equal As Integers    ${actual_total}    ${expected_total}

Basket Total Price Should Increase By
    [Documentation]    Verify that the basket total increased by the expected amount in cents.
    [Arguments]    ${before_total}
    ...    ${increase_amount}
    ${expected_total}=    Evaluate    int($before_total) + int($increase_amount)
    Basket Total Price Should Be In Cents    ${expected_total}

Prepare Logged In Basket With One Product
    [Documentation]    Create an account, sign in, add one product, open the basket page, and return the email.
    ${email}=    Create Generated Account
    Open Login Page
    Submit Login Credentials    ${email}    ${DEFAULT_ACCOUNT_PASSWORD}
    Successful Login Should Be Visible
    Search For Product    ${SEARCH_TERM}
    Add First Visible Product To Basket
    Close Basket Snackbar If Present
    Open Basket
    RETURN    ${email}

Increase First Basket Item Quantity By One
    [Documentation]    Increase the first basket row quantity by one and wait for the updated quantity.
    ${before_quantity}=    Read First Basket Item Quantity
    Click    ${FIRST_BASKET_ITEM_PLUS_BUTTON_LOCATOR}
    ${expected_quantity}=    Evaluate    int($before_quantity) + 1
    Basket Should Show Product Quantity    ${expected_quantity}

Read First Basket Item Quantity
    [Documentation]    Return the visible quantity value for the first basket row.
    ${quantity_text}=    Get Text    ${FIRST_BASKET_ITEM_QUANTITY_LOCATOR}
    ${quantity}=    Strip String    ${quantity_text}
    RETURN    ${quantity}

Read First Basket Item Price In Cents
    [Documentation]    Return the first basket row unit price as an integer number of cents.
    ${price_text}=    Get Text    ${FIRST_BASKET_ITEM_PRICE_LOCATOR}
    ${price_cents}=    Parse Price Text To Cents    ${price_text}
    RETURN    ${price_cents}

Read Basket Total Price In Cents
    [Documentation]    Return the basket total price as an integer number of cents.
    ${price_text}=    Get Text    ${BASKET_TOTAL_PRICE_LOCATOR}
    ${price_cents}=    Parse Price Text To Cents    ${price_text}
    RETURN    ${price_cents}

Parse Price Text To Cents
    [Documentation]    Extract a decimal price from UI text and convert it to cents.
    [Arguments]    ${price_text}
    ${normalized}=    Evaluate
    ...    __import__("re").search(r"(\\d+[\\.,]\\d+|\\d+)", str($price_text)).group(1).replace(',', '.')
    ${price_cents}=    Evaluate    int(round(float($normalized) * 100))
    RETURN    ${price_cents}

Close Basket Snackbar If Present
    [Documentation]    Close the basket snackbar when it is currently visible.
    Click If Visible    ${BASKET_SNACKBAR_CLOSE_LOCATOR}
