*** Settings ***
Documentation       UI-only Robot Framework demo coverage for OWASP Juice Shop.

Resource            ../resources/juice_shop.resource
Resource            ../resources/browser_setup.resource
Resource            ../variables/environment.resource

Test Setup          Open Shop Homepage
Test Teardown       Handle Test Cleanup


*** Test Cases ***
Homepage Smoke
    [Documentation]    Verify that the webshop homepage loads and shows the catalog.
    Catalog Should Show Products

Product Discovery
    [Documentation]    Verify that a shopper can search and still see matching catalog results.
    Search For Product    ${SEARCH_TERM}
    Catalog Should Show Products

Product Details
    [Documentation]    Verify that a shopper can open the product details dialog.
    Search For Product    ${SEARCH_TERM}
    Open First Product Details
    Details Dialog Should Be Visible
    Close Product Details
