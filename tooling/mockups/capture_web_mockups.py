from __future__ import annotations

import json
import time
from pathlib import Path

from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait


ROOT = Path(__file__).resolve().parents[2]
RAW_DIR = ROOT / "output" / "raw"
BASE_URL = "http://127.0.0.1:8123"

SESSION = {
    "access_token": "demo-access-token",
    "refresh_token": "demo-refresh-token",
    "user": {
        "id": "ux-mockup-user",
        "email": "talgat.student@zerdestudy.app",
        "roles": [
            {
                "id": "student-role",
                "code": "student",
                "name": "Student",
            }
        ],
        "is_active": True,
        "created_at": "2026-03-17T09:00:00.000Z",
    },
}

ROUTES = [
    ("home", "/home"),
    ("tree", "/tree"),
    ("learn", "/learn"),
    ("ai", "/ai"),
    ("profile", "/profile"),
]


def build_desktop_driver() -> webdriver.Chrome:
    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--disable-gpu")
    options.add_argument("--hide-scrollbars")
    options.add_argument("--window-size=1600,1000")
    options.add_argument("--force-device-scale-factor=1.5")
    return webdriver.Chrome(options=options, service=Service())


def build_mobile_driver() -> webdriver.Chrome:
    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--disable-gpu")
    options.add_argument("--hide-scrollbars")
    options.add_experimental_option(
        "mobileEmulation",
        {
            "deviceMetrics": {
                "width": 430,
                "height": 932,
                "pixelRatio": 2.0,
            },
            "userAgent": (
                "Mozilla/5.0 (Linux; Android 14; Pixel 7) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/146.0.0.0 Mobile Safari/537.36"
            ),
        },
    )
    return webdriver.Chrome(options=options, service=Service())


def wait_for_flutter(driver: webdriver.Chrome) -> None:
    wait = WebDriverWait(driver, 20)
    try:
        wait.until(
            lambda d: d.execute_script(
                "return document.readyState === 'complete' && "
                "(document.querySelector('flutter-view') !== null || "
                "document.querySelector('flt-glass-pane') !== null);"
            )
        )
    except TimeoutException:
        time.sleep(3)
    else:
        time.sleep(2.5)


def prime_local_storage(driver: webdriver.Chrome) -> None:
    driver.get(BASE_URL)
    wait_for_flutter(driver)
    raw_session = json.dumps(SESSION, ensure_ascii=False)
    driver.execute_script(
        """
        const authKey = 'flutter.zerdestudy_auth_session_v1';
        const demoStateKey = 'flutter.zerdestudy_demo_state_v4';
        window.localStorage.removeItem(demoStateKey);
        window.localStorage.setItem(authKey, JSON.stringify(arguments[0]));
        """,
        raw_session,
    )


def capture_routes(driver: webdriver.Chrome, viewport_slug: str) -> None:
    prime_local_storage(driver)
    for slug, route in ROUTES:
        driver.get(f"{BASE_URL}/#{route}")
        wait_for_flutter(driver)
        destination = RAW_DIR / f"{viewport_slug}-{slug}.png"
        driver.save_screenshot(str(destination))


def main() -> None:
    RAW_DIR.mkdir(parents=True, exist_ok=True)

    desktop = build_desktop_driver()
    try:
        capture_routes(desktop, "desktop")
    finally:
        desktop.quit()

    mobile = build_mobile_driver()
    try:
        capture_routes(mobile, "mobile")
    finally:
        mobile.quit()


if __name__ == "__main__":
    main()
