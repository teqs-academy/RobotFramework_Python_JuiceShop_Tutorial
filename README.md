# Robot Framework Webshop Demo

This repository contains a demo project for UI-only webshop testing with `Python + Robot Framework + Browser` against `OWASP Juice Shop` in a docker container. The Robot test suites run locally and in GitHub Actions.

## What It Covers

- Homepage, product search, product details, basket, and login flows
- CSV and Excel test-data examples
- Native Robot reports, screenshots on failure, and GitHub Pages publishing for `main`
- Robot Framework Style Guide checks through Robocop

## Prerequisites

Make sure you have:
- Python 3.11+
- Docker Desktop running, or another Docker installation with `docker` available on PATH
- Node.js
- Git

Clone and install the project

```bash
git clone <repository-url>
cd robot_framework_demo
python -m pip install -e ".[dev]"
rfbrowser init
```

Start the webshop container:

```bash
docker compose -f webshop_app/docker-compose.yml up -d
```

The webshop should now be available on: `http://127.0.0.1:3000`

## Project Structure

- `.github/workflows/ui-tests.yml` contains the GitHub Actions pipeline.
- `scripts/` contains helper scripts grouped by purpose.
    - `wait_for_url.py` performs the shared readiness polling used by CI and local runs.
    - `reporting/build_pages_site.py` copies the latest native Robot outputs into a static site folder and writes a landing page for GitHub Pages.
    - `test_support/search_cases.py` contains Python-backed helper file, to read CSV files.

- `tests/`
    - `data/` contains CSV- and Excel-based scenario input for search coverage.
    - `robot/` contains business-readable Robot suites.
    - `resources/` contains reusable centralized keywords and UI locators.
    - `variables/` contains environment and browser settings.

- `webshop_app/docker-compose.yml` Docker Compose configuration for `OWASP Juice Shop` container.
- `pyproject.toml` defines the Python project metadata and dependencies, including `robotframework-browser`, `robotframework-datadriver`, and `rpaframework`.

## Starting A Test

You can start tests with:

```bash
# Run all suites
python -m robot --outputdir results tests/robot

# Run one suite
python -m robot --outputdir results tests/robot/basket.robot

# Run a single test case
python -m robot --outputdir results --test "Homepage Smoke" tests/robot/shop_journeys.robot

# Record a video of the tests
python -m robot --outputdir results --variable RECORD_VIDEO:True --variable HEADLESS:False tests/robot

# Check Robot formatting and style
python -m robocop format --check tests
```

When a test is finished, you can open `results/report.html` for the summary and `results/log.html` for keyword-level details.

When you are done testing, you can stop the running webshop container:

```bash
docker compose -f webshop_app/docker-compose.yml down --remove-orphans
```

## Test Data Examples

Search coverage demonstrates three data-reading approaches:

- `search_method_1_DataDriver.robot`: DataDriver reads `search_keywords_datadriver.csv` and reports one test per row.
- `search_method_2_Python_Reader.robot`: Python `csv.DictReader` validates and exposes rows from `search_keywords.csv`.
- `search_method_3_RPA_Excel_Files.robot`: `RPA.Excel.Files` reads `search_keywords.xlsx`.

## GitHub Actions Workflow

The workflow:

- runs on pull requests
- runs on pushes to `main`
- keeps reporting native to Robot

The pipeline:

1. checks out the repository
2. sets up Python
3. installs the project dependencies
4. initializes the Browser library and Playwright side
5. validates the code with the Robot Style Guide
6. starts Juice Shop with Docker Compose
7. waits until the app is reachable
8. runs the Robot UI suite directly
9. uploads `results/` as the raw build artifact
10. builds a static site from the same Robot outputs
11. deploys that site to GitHub Pages on pushes to `main`
12. stops the webshop container

To use GitHub Pages for seeing the test results, make sure you have Pages enabled. Set Pages to build from `GitHub Actions` in the repository settings.

## Conventions

- [Robot Framework User Guide](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)
- [Robot Framework Browser Library](https://docs.robotframework.org/docs/different_libraries/browser)
- [Robot Framework Style Guide](https://docs.robotframework.org/docs/style_guide)
