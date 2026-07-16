"""Wait until a URL becomes reachable before continuing a test or CI flow."""

from __future__ import annotations

import argparse
import http.client
import math
import socket
import sys
import time
import urllib.error
import urllib.request


TRANSIENT_NETWORK_ERRORS = (
    ConnectionResetError,
    TimeoutError,
    socket.timeout,
    http.client.BadStatusLine,
    http.client.RemoteDisconnected,
)


def positive_number(value: str) -> float:
    """Return a positive command-line number or raise a clear argument error."""
    number = float(value)
    if not math.isfinite(number) or number <= 0:
        raise argparse.ArgumentTypeError("must be a finite number greater than zero")
    return number


def parse_args() -> argparse.Namespace:
    """Parse the target URL and polling settings from the command line."""
    parser = argparse.ArgumentParser()
    parser.add_argument("url")
    parser.add_argument("--timeout", type=positive_number, default=120.0)
    parser.add_argument("--interval", type=positive_number, default=2.0)
    parser.add_argument("--request-timeout", type=positive_number, default=10.0)
    return parser.parse_args()


def main() -> int:
    """Poll the URL until it responds or the timeout expires."""
    args = parse_args()
    deadline = time.monotonic() + args.timeout

    while (remaining := deadline - time.monotonic()) > 0:
        try:
            with urllib.request.urlopen(
                args.url, timeout=min(args.request_timeout, remaining)
            ) as response:
                # Treat any reachable application response as "ready enough"
                # for this orchestration flow, even if the page returns a
                # redirect or a client-side error page.
                if 200 <= response.status < 500:
                    print(f"Ready: {args.url} ({response.status})")
                    return 0
        except urllib.error.HTTPError as error:
            # urllib raises HTTPError for 4xx responses even though the app is
            # reachable. A client error still proves that startup completed.
            if 400 <= error.code < 500:
                print(f"Ready: {args.url} ({error.code})")
                return 0
        except (urllib.error.URLError, *TRANSIENT_NETWORK_ERRORS):
            # During container startup the TCP connection can exist before the
            # web app is fully ready, which may cause resets or incomplete
            # HTTP responses. These are retriable readiness failures.
            pass
        time.sleep(min(args.interval, max(0.0, deadline - time.monotonic())))

    print(f"Timeout waiting for {args.url}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
