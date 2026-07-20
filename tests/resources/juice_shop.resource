*** Settings ***
Documentation       Central Juice Shop locators and reusable UI interactions.

Library             Collections
Library             String
Library             Browser
Resource            browser_setup.resource


*** Variables ***
${CATALOG_CARD_LOCATOR}                 css=mat-card:visible
${FIRST_CATALOG_CARD_LOCATOR}           css=mat-card:visible >> nth=0
${SEARCH_OPEN_BUTTON_LOCATOR}           css=button[aria-label*="Open search" i]
${SEARCH_INPUT_LOCATOR}                 css=app-mat-search-bar input:visible,
...                                     input[aria-label*="search" i]:visible,
...                                     input[placeholder*="Search" i]:visible,
...                                     input[type="search"]:visible
${NO_RESULTS_LOCATOR}                   text=No results found
${PRODUCT_IMAGE_LOCATOR}                css=mat-card:visible img
${FIRST_PRODUCT_IMAGE_LOCATOR}          css=mat-card:visible img >> nth=0
${PRODUCT_NAME_LOCATOR}                 css=mat-card:visible .item-name, mat-card-title
${ADD_TO_BASKET_LOCATOR}                css=button[aria-label*="Add to Basket"], button[mattooltip*="Add to Basket"]
${FIRST_ADD_TO_BASKET_LOCATOR}          css=button[aria-label*="Add to Basket"],
...                                     button[mattooltip*="Add to Basket"] >> nth=0
${BASKET_BUTTON_LOCATOR}                css=button[aria-label*="shopping cart"],
...                                     button[mattooltip*="Show the shopping cart"]
${BASKET_COUNT_LOCATOR}                 css=button[aria-label*="shopping cart"] .warn-notification
${BASKET_PAGE_TITLE_LOCATOR}            css=app-basket h1
${BASKET_TOTAL_PRICE_LOCATOR}           css=#price
${BASKET_ITEM_ROW_LOCATOR}              css=mat-row, tr.mat-mdc-row, .basket-item
${PRODUCT_DETAILS_DIALOG_LOCATOR}       css=mat-dialog-container
${PRODUCT_DETAILS_CLOSE_LOCATOR}        css=mat-dialog-container button[aria-label*="Close"],
...                                     mat-dialog-container button[mat-dialog-close]


*** Keywords ***
Open Shop Homepage
    [Documentation]    Open the shop homepage, dismiss startup dialogs, and wait for the catalog to load.
    Open Browser To Shop
    Dismiss Startup Dialogs
    Wait Until Shop Catalog Loads

Wait Until Shop Catalog Loads
    [Documentation]    Wait until the first visible catalog card is rendered.
    Wait For Elements State    ${FIRST_CATALOG_CARD_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Dismiss Startup Dialogs
    [Documentation]    Dismiss the welcome and cookie dialogs when they are shown.
    Click If Visible    text=Dismiss
    Click If Visible    text=Me want it!

Search For Product
    [Documentation]    Search the catalog for the provided term and wait for the matching result state.
    [Arguments]    ${search_term}
    Ensure Search Input Is Ready
    Type Text    ${SEARCH_INPUT_LOCATOR}    ${search_term}
    Press Keys    ${SEARCH_INPUT_LOCATOR}    Enter
    Wait For Search State    ${search_term}

Wait For Search State
    [Documentation]    Wait for the catalog heading that corresponds to the current search input state.
    [Arguments]    ${search_term}
    ${normalized_search_term}=    Strip String    ${search_term}
    IF    $search_term == '' # Check for truly empty string
        Wait Until Shop Catalog Loads
    ELSE IF    $normalized_search_term == '' # Check for whitespace-only string
        Wait For Elements State    text=Search Results -    visible    ${BROWSER_TIMEOUT}
    ELSE
        Wait For Elements State    text=Search Results - ${normalized_search_term}    visible    ${BROWSER_TIMEOUT}
    END

Search Results Should Match
    [Documentation]    Search for a term and verify that the visible result count matches the expectation.
    [Arguments]    ${search_term}
    ...    ${expected_result_count}
    ${expected_count}=    Convert To Integer    ${expected_result_count}
    Search For Product    ${search_term}
    IF    $expected_count == 0
        Wait Until Keyword Succeeds    10x    300ms    No Results Message Should Be Visible
    ELSE
        Wait Until Keyword Succeeds    10x    300ms    Catalog Should Show Exact Product Count    ${expected_count}
    END

Ensure Search Input Is Ready
    [Documentation]    Open the search UI when needed and wait until the input field is visible.
    Click If Visible    ${SEARCH_OPEN_BUTTON_LOCATOR}
    Wait For Elements State    ${SEARCH_INPUT_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Open First Product Details
    [Documentation]    Open the details dialog for the first visible product card.
    Wait For Elements State    ${FIRST_PRODUCT_IMAGE_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    Click    ${FIRST_PRODUCT_IMAGE_LOCATOR}
    Wait For Elements State    ${PRODUCT_DETAILS_DIALOG_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Close Product Details
    [Documentation]    Close the visible product details dialog if it is open.
    Click If Visible    ${PRODUCT_DETAILS_CLOSE_LOCATOR}

Add First Visible Product To Basket
    [Documentation]    Add the first visible product to the basket and wait for the counter to increase.
    Wait For Elements State    ${FIRST_ADD_TO_BASKET_LOCATOR}    visible    ${BROWSER_TIMEOUT}
    ${before}=    Read Basket Count
    Click    ${FIRST_ADD_TO_BASKET_LOCATOR}
    Wait Until Keyword Succeeds    10x    300ms    Basket Count Should Be Greater Than    ${before}

Open Basket
    [Documentation]    Open the basket page and wait until its title is visible.
    Click    ${BASKET_BUTTON_LOCATOR}
    Wait For Elements State    ${BASKET_PAGE_TITLE_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Read Basket Count
    [Documentation]    Return the visible basket counter value or zero when no counter is shown.
    ${counter_count}=    Get Element Count    ${BASKET_COUNT_LOCATOR}
    IF    $counter_count == 0    RETURN    0
    ${count_text}=    Get Text    ${BASKET_COUNT_LOCATOR}
    ${normalized_count}=    Strip String    ${count_text}
    RETURN    ${normalized_count}

Basket Count Should Be Greater Than
    [Documentation]    Verify that the current basket count is greater than the provided baseline.
    [Arguments]    ${baseline}
    ${current}=    Read Basket Count
    ${current_int}=    Convert To Integer    ${current}
    ${baseline_int}=    Convert To Integer    ${baseline}
    Should Be True    ${current_int} > ${baseline_int}

Catalog Should Show Products
    [Documentation]    Verify that at least one visible catalog card is present.
    ${cards}=    Get Element Count    ${CATALOG_CARD_LOCATOR}
    Should Be True    ${cards} >= 1

Catalog Should Show Exact Product Count
    [Documentation]    Verify that the visible catalog card count matches the expected value.
    [Arguments]    ${expected_count}
    ${cards}=    Get Element Count    ${CATALOG_CARD_LOCATOR}
    Should Be Equal As Integers    ${cards}    ${expected_count}

No Results Message Should Be Visible
    [Documentation]    Wait until the no-results message is visible.
    Wait For Elements State    ${NO_RESULTS_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Details Dialog Should Be Visible
    [Documentation]    Wait until the product details dialog is visible.
    Wait For Elements State    ${PRODUCT_DETAILS_DIALOG_LOCATOR}    visible    ${BROWSER_TIMEOUT}

Click If Visible
    [Documentation]    Click the locator with force enabled when it becomes visible within one second.
    [Arguments]    ${locator}
    ${is_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${locator}    visible    1s
    IF    ${is_visible}    Click With Options    ${locator}    force=True
