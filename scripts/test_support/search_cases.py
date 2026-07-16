"""Load validated search rows from the CSV file for the Robot variable file."""

from __future__ import annotations

import csv
from pathlib import Path

__all__ = ["ROWS"]

EXPECTED_COLUMNS = (
    "Test Case Description",
    "Input",
    "Expectation",
    "Documentation",
)


def _load_rows() -> list[dict[str, int | str]]:
    """Return validated and normalized rows from the search data file."""
    data_path = (
        Path(__file__).resolve().parents[2]
        / "tests"
        / "data"
        / "search_keywords.csv"
    )
    with data_path.open(encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != list(EXPECTED_COLUMNS):
            raise ValueError(
                f"{data_path} must use these columns in this order: "
                f"{', '.join(EXPECTED_COLUMNS)}"
            )

        rows: list[dict[str, int | str]] = []
        for row_number, row in enumerate(reader, start=2):
            try:
                expectation = int(row["Expectation"] or "")
            except ValueError as error:
                raise ValueError(
                    f"{data_path}:{row_number} has an invalid Expectation value"
                ) from error

            if expectation < 0:
                raise ValueError(
                    f"{data_path}:{row_number} Expectation cannot be negative"
                )

            rows.append(
                {
                    "input": row["Input"] or "",
                    "expectation": expectation,
                }
            )

    if not rows:
        raise ValueError(f"{data_path} must contain at least one search row")
    return rows


ROWS = _load_rows()
