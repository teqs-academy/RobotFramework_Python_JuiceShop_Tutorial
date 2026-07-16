"""Build a small GitHub Pages site from the latest Robot Framework results."""

from __future__ import annotations

import argparse
import html
import os
import shutil
from datetime import UTC, datetime
from pathlib import Path


def parse_args() -> argparse.Namespace:
    """Parse the source results directory and the destination site directory."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", default="results")
    parser.add_argument("--site-dir", default="pages-site")
    return parser.parse_args()


def reset_directory(path: Path) -> None:
    """Recreate the destination directory so the site only contains fresh files."""
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)


def validate_paths(results_dir: Path, site_dir: Path) -> None:
    """Reject paths that would delete or recursively copy Robot results."""
    if site_dir == results_dir or results_dir.is_relative_to(site_dir):
        raise ValueError("--site-dir must not be the results directory or its parent")
    if site_dir.is_relative_to(results_dir):
        raise ValueError("--site-dir must not be inside --results-dir")


def copy_results(results_dir: Path, site_dir: Path) -> list[str]:
    """Copy every available Robot result file into the Pages site directory."""
    copied_files: list[str] = []
    if not results_dir.exists():
        return copied_files

    for item in results_dir.iterdir():
        if item.is_symlink():
            print(f"Skipping symbolic link in results: {item.name}")
            continue
        destination = site_dir / item.name
        if item.is_dir():
            shutil.copytree(item, destination)
        else:
            shutil.copy2(item, destination)
        copied_files.append(item.name)

    return sorted(copied_files)


def build_run_url() -> str | None:
    """Return the GitHub Actions run URL when the workflow metadata is available."""
    server_url = os.environ.get("GITHUB_SERVER_URL")
    repository = os.environ.get("GITHUB_REPOSITORY")
    run_id = os.environ.get("GITHUB_RUN_ID")
    if not server_url or not repository or not run_id:
        return None
    return f"{server_url}/{repository}/actions/runs/{run_id}"


def build_metadata() -> dict[str, str]:
    """Collect display metadata so the landing page explains which run it shows."""
    metadata = {
        "repository": os.environ.get("GITHUB_REPOSITORY", "local run"),
        "branch": os.environ.get("GITHUB_REF_NAME", "local"),
        "sha": os.environ.get("GITHUB_SHA", "")[:7] or "local",
        "run_number": os.environ.get("GITHUB_RUN_NUMBER", "local"),
        "generated_at": datetime.now(UTC).strftime("%Y-%m-%d %H:%M:%S UTC"),
    }
    run_url = build_run_url()
    if run_url:
        metadata["run_url"] = run_url
    return metadata


def write_index(site_dir: Path, copied_files: list[str], metadata: dict[str, str]) -> None:
    """Create a simple landing page that links to the native Robot output files."""
    report_exists = "report.html" in copied_files
    log_exists = "log.html" in copied_files
    output_exists = "output.xml" in copied_files

    run_link = ""
    if "run_url" in metadata:
        run_url = html.escape(metadata["run_url"], quote=True)
        run_link = f'<p><a href="{run_url}">Open the GitHub Actions run</a></p>'

    available_links = []
    if report_exists:
        available_links.append('<li><a href="report.html">report.html</a></li>')
    if log_exists:
        available_links.append('<li><a href="log.html">log.html</a></li>')
    if output_exists:
        available_links.append('<li><a href="output.xml">output.xml</a></li>')

    if available_links:
        links_html = "\n".join(available_links)
        status_html = "<p>The latest published Robot results are available below.</p>"
    else:
        links_html = ""
        status_html = (
            "<p>No Robot result files were available for this run. "
            "Check the linked workflow run for setup or startup failures.</p>"
        )

    html_content = f"""<!DOCTYPE html>
<html lang=\"en\">
<head>
  <meta charset=\"utf-8\">
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
  <title>Robot Framework Webshop Demo Results</title>
  <style>
    :root {{
      color-scheme: light;
      --bg: #f4f1ea;
      --panel: #fffdf8;
      --text: #1f2933;
      --muted: #52606d;
      --accent: #0b6e4f;
      --border: #d9d2c3;
    }}
    body {{
      margin: 0;
      font-family: Georgia, "Times New Roman", serif;
      background: linear-gradient(180deg, #efe8da 0%, var(--bg) 100%);
      color: var(--text);
    }}
    main {{
      max-width: 760px;
      margin: 48px auto;
      padding: 32px;
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 18px;
      box-shadow: 0 14px 40px rgba(31, 41, 51, 0.08);
    }}
    h1 {{
      margin-top: 0;
      font-size: 2.2rem;
    }}
    p, li {{
      line-height: 1.6;
    }}
    .meta {{
      color: var(--muted);
      font-size: 0.98rem;
    }}
    a {{
      color: var(--accent);
    }}
    ul {{
      padding-left: 1.2rem;
    }}
    code {{
      font-family: Consolas, monospace;
      background: #f0ebe1;
      padding: 0.15rem 0.35rem;
      border-radius: 0.25rem;
    }}
  </style>
</head>
<body>
  <main>
    <h1>Latest Robot Results</h1>
    <p class=\"meta\">Repository: <code>{html.escape(metadata['repository'])}</code><br>
    Branch: <code>{html.escape(metadata['branch'])}</code><br>
    Commit: <code>{html.escape(metadata['sha'])}</code><br>
    Run number: <code>{html.escape(metadata['run_number'])}</code><br>
    Generated: <code>{html.escape(metadata['generated_at'])}</code></p>
    {status_html}
    {run_link}
    <ul>
      {links_html}
    </ul>
    <p>Robot screenshots and other linked assets remain available through the native report files when they were produced during the run.</p>
  </main>
</body>
</html>
"""
    (site_dir / "index.html").write_text(html_content, encoding="utf-8")
    (site_dir / ".nojekyll").write_text("", encoding="utf-8")


def main() -> int:
    """Copy Robot outputs and generate the landing page for GitHub Pages."""
    args = parse_args()
    results_dir = Path(args.results_dir).resolve()
    site_dir = Path(args.site_dir).resolve()

    validate_paths(results_dir, site_dir)
    reset_directory(site_dir)
    copied_files = copy_results(results_dir, site_dir)
    metadata = build_metadata()
    write_index(site_dir, copied_files, metadata)

    print(f"Built GitHub Pages site in {site_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
