*** Settings ***
Documentation       Basket coverage for anonymous and authenticated OWASP Juice Shop shopping flows.

Resource            ../resources/basket.resource
Resource            ../resources/browser_setup.resource

Test Setup          Open Shop Homepage
Test Teardown       Handle Test Cleanup


*** Test Cases ***
Anonymous Basket Starts Empty
    [Documentation]    Verify that an anonymous shopper sees an empty basket before adding products.
    Open Basket
    Basket Should Be Empty
    Basket Title Should Show Owner    anonymous

Anonymous Basket Shows One Added Product
    [Documentation]    Verify that one anonymous add action is reflected in the basket.
    Add First Visible Product To Basket Multiple Times    1
    Open Basket
    Basket Should Show Product Quantity    1
    Basket Count Should Be    1
    Basket Total Price Should Match Visible Item Price

Anonymous Basket Shows Three Added Products
    [Documentation]    Verify that three anonymous add actions are reflected in the basket.
    Add First Visible Product To Basket Multiple Times    3
    Open Basket
    Basket Should Show Product Quantity    3
    Basket Count Should Be    3
    Basket Total Price Should Match Visible Item Price

Authenticated Basket Quantity Update Changes Total Price
    [Documentation]    Verify that a signed-in shopper can increase basket quantity and total price.
    Prepare Logged In Basket With One Product
    Basket Title Should Show Owner    ${LOGIN_ACCOUNT_EMAIL}
    Basket Should Show Product Quantity    1
    ${before_total}=    Read Basket Total Price In Cents
    ${unit_price}=    Read First Basket Item Price In Cents
    Increase First Basket Item Quantity By One
    Basket Count Should Be    2
    Basket Total Price Should Increase By    ${before_total}    ${unit_price}
