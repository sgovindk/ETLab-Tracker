"""
ETLab Attendance Scraper
========================
Uses Selenium to log into ETLab and scrape attendance data.
Runs Chrome in headless mode for server deployment.

Debug mode saves page HTML to backend/debug/ folder for inspection.
"""

import os
import re
import time
import logging
from typing import Optional
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.common.exceptions import (
    TimeoutException,
    NoSuchElementException,
    WebDriverException,
    StaleElementReferenceException,
)

try:
    from webdriver_manager.chrome import ChromeDriverManager
except ImportError:
    ChromeDriverManager = None

logger = logging.getLogger(__name__)

# Create debug directory
DEBUG_DIR = os.path.join(os.path.dirname(__file__), "debug")
os.makedirs(DEBUG_DIR, exist_ok=True)


def _save_debug(filename: str, content: str):
    """Save HTML/text to debug folder for inspection."""
    try:
        path = os.path.join(DEBUG_DIR, filename)
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
        logger.info("DEBUG: Saved %s (%d chars)", path, len(content))
    except Exception as e:
        logger.warning("Could not save debug file %s: %s", filename, e)


class ETLabScraper:
    """Headless Chrome scraper for sctce.etlab.in attendance portal."""

    BASE_URL = "https://sctce.etlab.in"
    LOGIN_URL = f"{BASE_URL}/user/login"

    # Attendance page paths – ordered by likelihood for sctce.etlab.in
    ATTENDANCE_PATHS = [
        "/student/attendance",                              # sidebar link
        "/ktuacademics/student/viewattendancesubject",      # actual data page (needs student ID)
        "/ktuacademics/student/viewattendance",
        "/ktuacademics/student/attendance",
        "/student/viewattendance",
    ]

    def __init__(self):
        self.driver: Optional[webdriver.Chrome] = None

    # ── Driver management ────────────────────────────────────────────
    def _build_driver(self) -> webdriver.Chrome:
        opts = Options()
        opts.add_argument("--headless=new")
        opts.add_argument("--no-sandbox")
        opts.add_argument("--disable-dev-shm-usage")
        opts.add_argument("--disable-gpu")
        opts.add_argument("--window-size=1920,1080")
        opts.add_argument("--disable-extensions")
        opts.add_argument("--disable-blink-features=AutomationControlled")
        opts.add_experimental_option("excludeSwitches", ["enable-automation"])
        opts.add_argument(
            "user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/121.0.0.0 Safari/537.36"
        )

        if ChromeDriverManager:
            service = Service(ChromeDriverManager().install())
        else:
            service = Service()

        driver = webdriver.Chrome(service=service, options=opts)
        driver.implicitly_wait(5)
        return driver

    def _ensure_driver(self):
        if self.driver is None:
            self.driver = self._build_driver()

    def close(self):
        if self.driver:
            try:
                self.driver.quit()
            except Exception:
                pass
            self.driver = None

    # ── Login ────────────────────────────────────────────────────────
    def login(self, username: str, password: str) -> dict:
        try:
            self._ensure_driver()
            logger.info("Navigating to login page: %s", self.LOGIN_URL)
            self.driver.get(self.LOGIN_URL)
            time.sleep(3)

            _save_debug("01_login_page.html", self.driver.page_source)
            logger.info("Login page URL: %s", self.driver.current_url)
            logger.info("Login page title: %s", self.driver.title)

            wait = WebDriverWait(self.driver, 15)

            # ETLab uses Yii framework – typical IDs
            username_selectors = [
                (By.ID, "LoginForm_username"),
                (By.NAME, "LoginForm[username]"),
                (By.CSS_SELECTOR, "input[name*='username']"),
                (By.CSS_SELECTOR, "input[type='text']"),
                (By.CSS_SELECTOR, "input[type='email']"),
            ]
            password_selectors = [
                (By.ID, "LoginForm_password"),
                (By.NAME, "LoginForm[password]"),
                (By.CSS_SELECTOR, "input[name*='password']"),
                (By.CSS_SELECTOR, "input[type='password']"),
            ]

            user_field = self._find_first(username_selectors, wait)
            pass_field = self._find_first(password_selectors, wait)

            if not user_field or not pass_field:
                logger.error("Could not locate login fields on page")
                _save_debug("01_login_fields_not_found.html", self.driver.page_source)
                return {"success": False, "message": "Could not locate login fields"}

            logger.info("Found login fields, entering credentials...")
            user_field.clear()
            user_field.send_keys(username)
            pass_field.clear()
            pass_field.send_keys(password)

            # Submit
            submit_selectors = [
                (By.CSS_SELECTOR, "input[type='submit']"),
                (By.CSS_SELECTOR, "button[type='submit']"),
                (By.CSS_SELECTOR, ".btn-login"),
                (By.CSS_SELECTOR, "button.btn"),
                (By.CSS_SELECTOR, ".login-btn"),
            ]
            btn = self._find_first(submit_selectors, wait)
            if btn:
                logger.info("Clicking submit button...")
                btn.click()
            else:
                logger.info("No submit button found, submitting form...")
                pass_field.submit()

            time.sleep(4)

            _save_debug("02_after_login.html", self.driver.page_source)
            logger.info("After login URL: %s", self.driver.current_url)
            logger.info("After login title: %s", self.driver.title)

            # Detect success (URL should change away from /login)
            if "login" in self.driver.current_url.lower():
                try:
                    err = self.driver.find_element(
                        By.CSS_SELECTOR, ".errorMessage, .alert-danger, .error, .help-block"
                    )
                    msg = err.text.strip() or "Invalid credentials"
                    logger.error("Login failed with message: %s", msg)
                    return {"success": False, "message": msg}
                except NoSuchElementException:
                    logger.error("Login failed – still on login page")
                    return {"success": False, "message": "Login failed – credentials may be incorrect"}

            logger.info("Login successful – redirected to %s", self.driver.current_url)
            return {"success": True, "message": "Login successful"}

        except TimeoutException:
            logger.exception("Login page timed out")
            return {"success": False, "message": "Login page timed out"}
        except WebDriverException as exc:
            logger.exception("Browser error during login")
            return {"success": False, "message": f"Browser error: {exc.msg}"}
        except Exception as exc:
            logger.exception("Unexpected error during login")
            return {"success": False, "message": str(exc)}

    # ── Attendance scraping ──────────────────────────────────────────
    def get_attendance(self) -> dict:
        """Navigate to the attendance page and scrape subject-wise data."""
        if not self.driver:
            return {"success": False, "message": "Not logged in", "data": []}

        logger.info("=" * 60)
        logger.info("Starting attendance scrape...")
        logger.info("Current URL before navigation: %s", self.driver.current_url)

        # ── Step 1: Navigate to the attendance section ──
        # ETLab flow: /student/attendance → may show semester/subject links
        #             → /ktuacademics/student/viewattendancesubject/<STUDENT_ID>
        #             has the actual data table.

        attendance_page_found = False

        # Strategy A: Go to /student/attendance first (sidebar link)
        # This page shows a calendar/timetable view, NOT the subject-wise summary.
        # We need to find and click the "Attendance By Subject" tab/link which
        # points to /ktuacademics/student/viewattendancesubject/<STUDENT_ID>
        try:
            url = f"{self.BASE_URL}/student/attendance"
            logger.info("Step 1: Navigating to %s", url)
            self.driver.get(url)
            time.sleep(3)

            if "login" in self.driver.current_url.lower():
                logger.warning("Redirected to login – session may have expired")
            else:
                _save_debug("03_student_attendance.html", self.driver.page_source)
                logger.info("At URL: %s | Title: %s", self.driver.current_url, self.driver.title)

                # ALWAYS look for viewattendancesubject link first —
                # the table on /student/attendance is a calendar, NOT the summary
                attendance_page_found = self._follow_attendance_subject_link()

        except Exception as e:
            logger.warning("Error on /student/attendance: %s", e)

        # Strategy B: Try direct viewattendancesubject URL patterns
        if not attendance_page_found:
            logger.info("Strategy B: Trying direct attendance URLs...")
            for path in self.ATTENDANCE_PATHS:
                if path == "/student/attendance":
                    continue  # Already tried above
                url = f"{self.BASE_URL}{path}"
                try:
                    logger.info("Trying: %s", url)
                    self.driver.get(url)
                    time.sleep(3)
                    if "login" in self.driver.current_url.lower():
                        continue
                    # Check for 404 error text
                    if "error 404" in self.driver.page_source.lower():
                        logger.info("Got 404 at %s", url)
                        continue
                    if "unable to find" in self.driver.page_source.lower():
                        logger.info("Action not found at %s", url)
                        continue

                    tables = self.driver.find_elements(By.TAG_NAME, "table")
                    if tables and len(tables[0].find_elements(By.TAG_NAME, "tr")) > 2:
                        logger.info("Found attendance table at %s", url)
                        attendance_page_found = True
                        break

                    # Check for links to the real page
                    if self._follow_attendance_subject_link():
                        attendance_page_found = True
                        break
                except Exception as e:
                    logger.warning("Error at %s: %s", url, e)

        # Strategy C: Search for links on dashboard
        if not attendance_page_found:
            logger.info("Strategy C: Searching dashboard for attendance links...")
            self.driver.get(self.BASE_URL)
            time.sleep(3)
            _save_debug("03_dashboard.html", self.driver.page_source)

            # Click sidebar "Attendance" link
            try:
                link = self.driver.find_element(
                    By.XPATH, "//a[contains(@href, '/student/attendance')]"
                )
                logger.info("Found sidebar link: %s", link.get_attribute("href"))
                link.click()
                time.sleep(3)
                attendance_page_found = self._follow_attendance_subject_link()
            except NoSuchElementException:
                logger.warning("No /student/attendance link in sidebar")

        # Strategy D: Search all links on current page for attendance-related URLs
        if not attendance_page_found:
            logger.info("Strategy D: Brute-force link search...")
            try:
                all_links = self.driver.find_elements(By.TAG_NAME, "a")
                for link in all_links:
                    try:
                        href = link.get_attribute("href") or ""
                        if "viewattendancesubject" in href.lower() or "viewattendance" in href.lower():
                            logger.info("Found attendance link: %s -> %s", link.text, href)
                            self.driver.get(href)
                            time.sleep(3)
                            if "error" not in self.driver.page_source.lower()[:500]:
                                attendance_page_found = True
                                break
                    except StaleElementReferenceException:
                        continue
            except Exception as e:
                logger.warning("Brute-force link search failed: %s", e)

        if not attendance_page_found:
            logger.error("Could not navigate to attendance page after all strategies")
            self._save_all_links()
            return {
                "success": False,
                "message": "Could not navigate to attendance page. Check backend/debug/",
                "data": [],
            }

        # ── Step 2: Parse the attendance table ──
        _save_debug("05_final_attendance_page.html", self.driver.page_source)
        logger.info("Parsing attendance from: %s", self.driver.current_url)
        return self._parse_attendance_table()

    def _follow_attendance_subject_link(self) -> bool:
        """
        On the current page, look for links pointing to viewattendancesubject
        (the actual data page with student ID). Click the first one found.
        Returns True if successfully navigated to a page with attendance data.
        """
        try:
            # Look for links containing 'viewattendancesubject'
            selectors = [
                "//a[contains(@href, 'viewattendancesubject')]",
                "//a[contains(@href, 'viewAttendanceSubject')]",
                "//a[contains(@href, 'viewattendance')]",
                "//a[contains(@href, 'viewAttendance')]",
            ]
            for sel in selectors:
                links = self.driver.find_elements(By.XPATH, sel)
                if links:
                    href = links[0].get_attribute("href")
                    logger.info("Found subject attendance link: '%s' -> %s", links[0].text.strip(), href)
                    self.driver.get(href)
                    time.sleep(3)

                    # Verify we got a real page (not 404)
                    src = self.driver.page_source.lower()
                    if "error 404" in src or "unable to find" in src:
                        logger.warning("Link led to 404: %s", href)
                        continue

                    _save_debug("04_viewattendancesubject.html", self.driver.page_source)
                    logger.info("Navigated to: %s", self.driver.current_url)
                    return True

            # Also try: the page might have buttons or JS links
            # Check if the current URL itself is the attendance page
            if "viewattendancesubject" in self.driver.current_url.lower():
                logger.info("Already on viewattendancesubject page")
                return True

            # Try finding any link with "View" text near attendance context
            try:
                view_links = self.driver.find_elements(
                    By.XPATH,
                    "//a[contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'), 'view')]"
                )
                for vl in view_links:
                    href = vl.get_attribute("href") or ""
                    if "attendance" in href.lower():
                        logger.info("Found 'View' link: %s -> %s", vl.text.strip(), href)
                        self.driver.get(href)
                        time.sleep(3)
                        if "error" not in self.driver.page_source.lower()[:500]:
                            return True
            except Exception:
                pass

            logger.info("No viewattendancesubject link found on page")
            return False

        except Exception as e:
            logger.warning("Error following attendance subject link: %s", e)
            return False

    def _save_all_links(self):
        """Save all links on current page for debugging."""
        try:
            all_links = self.driver.find_elements(By.TAG_NAME, "a")
            link_info = []
            for a in all_links:
                try:
                    link_info.append(f"{a.text.strip()} -> {a.get_attribute('href')}")
                except StaleElementReferenceException:
                    continue
            _save_debug("04_all_links.txt", "\n".join(link_info))
            logger.info("Saved %d links to debug/04_all_links.txt", len(link_info))
        except Exception:
            pass

    def _parse_attendance_table(self) -> dict:
        """
        Parse the ETLab attendance table.

        ETLab uses a PIVOTED table format:
          Headers:  UNi Reg No | Roll No | Name | AMT302 | AIT304 | ... | Total | Percentage
          Data row: SCT23AM058 | 358     | Name | 25/26 (96%) | 25/28 (89%) | ... | 140/154 | 91%

        Subject codes are COLUMN HEADERS. Each data cell is "attended/total (pct%)".
        """
        try:
            page_source = self.driver.page_source
            tables = self.driver.find_elements(By.TAG_NAME, "table")
            logger.info("Found %d table(s) on page", len(tables))

            attendance: list[dict] = []

            for idx, table in enumerate(tables):
                try:
                    rows = table.find_elements(By.TAG_NAME, "tr")
                    logger.info("Table %d: %d rows", idx, len(rows))
                    if len(rows) < 2:
                        continue

                    # ── Get header row ──
                    header_cells = rows[0].find_elements(By.TAG_NAME, "th")
                    if not header_cells:
                        header_cells = rows[0].find_elements(By.TAG_NAME, "td")
                    headers = [h.text.strip() for h in header_cells]
                    logger.info("Table %d headers: %s", idx, headers)

                    # ── Detect ETLab pivoted format ──
                    # Headers that are NOT subject codes
                    skip_headers = {
                        "uni reg no", "reg no", "roll no", "name", "total",
                        "percentage", "sl no", "sl", "#", "no", "register no",
                        "student name", "roll", "reg", "register number",
                    }

                    # Find subject columns: headers that look like subject codes
                    # (e.g., AMT302, AIT304, CST306, HUT300, etc.)
                    subject_columns: list[tuple[int, str]] = []
                    for col_idx, header in enumerate(headers):
                        h_lower = header.lower().strip()
                        if not h_lower or h_lower in skip_headers:
                            continue
                        # Subject codes typically: 2-4 letters + 3-4 digits (e.g., AMT302, CST306)
                        # Or they contain "/" like "25/26" — those are data, not headers
                        if re.match(r'^[A-Za-z]{2,5}\d{3,4}[A-Za-z]?$', header.strip()):
                            subject_columns.append((col_idx, header.strip()))
                            logger.info("  Subject column %d: %s", col_idx, header.strip())

                    if subject_columns:
                        logger.info("Detected ETLab PIVOTED table with %d subject columns", len(subject_columns))
                        # Parse each data row (usually just 1 for the student)
                        for row_idx, row in enumerate(rows[1:], start=1):
                            cols = row.find_elements(By.TAG_NAME, "td")
                            col_texts = [c.text.strip() for c in cols]
                            logger.info("  Data row %d: %s", row_idx, col_texts)

                            for sub_col_idx, sub_code in subject_columns:
                                if sub_col_idx >= len(col_texts):
                                    continue
                                cell_text = col_texts[sub_col_idx]
                                parsed = self._parse_attendance_cell(cell_text)
                                if parsed:
                                    subject = {
                                        "subject_code": sub_code,
                                        "subject_name": sub_code,  # ETLab only shows codes
                                        "hours_attended": parsed["attended"],
                                        "total_hours": parsed["total"],
                                        "percentage": parsed["percentage"],
                                    }
                                    logger.info("    %s: %d/%d (%.1f%%)",
                                                sub_code, parsed["attended"],
                                                parsed["total"], parsed["percentage"])
                                    attendance.append(subject)

                        if attendance:
                            break  # Found valid data

                    # ── Fallback: try traditional row-based format ──
                    if not attendance:
                        col_map = self._map_columns([h.lower() for h in headers])
                        if col_map:
                            logger.info("Table %d: traditional row format, col_map=%s", idx, col_map)
                            for row_idx, row in enumerate(rows[1:], start=1):
                                cols = row.find_elements(By.TAG_NAME, "td")
                                if len(cols) < max(col_map.values()) + 1:
                                    continue
                                try:
                                    code = cols[col_map["code"]].text.strip() if "code" in col_map else ""
                                    name = cols[col_map["name"]].text.strip() if "name" in col_map else ""
                                    attended = self._parse_int(cols[col_map["attended"]].text)
                                    total = self._parse_int(cols[col_map["total"]].text)
                                    pct_text = cols[col_map["percentage"]].text if "percentage" in col_map else ""
                                    percentage = self._parse_float(pct_text)
                                    if total == 0:
                                        continue
                                    if percentage == 0.0 and total > 0:
                                        percentage = round(attended / total * 100, 2)
                                    attendance.append({
                                        "subject_code": code or f"SUB{row_idx}",
                                        "subject_name": name or code or f"Subject {row_idx}",
                                        "hours_attended": attended,
                                        "total_hours": total,
                                        "percentage": percentage,
                                    })
                                except (ValueError, IndexError):
                                    continue
                            if attendance:
                                break

                except StaleElementReferenceException:
                    logger.warning("Table %d became stale, skipping", idx)
                    continue

            # ── Fallback: regex on page source for "NN/NN (NN%)" patterns ──
            if not attendance:
                logger.info("No table data, trying regex fallback on page source...")
                attendance = self._regex_parse_page(page_source)

            if not attendance:
                logger.warning("=" * 40)
                logger.warning("NO ATTENDANCE DATA FOUND")
                logger.warning("=" * 40)
                try:
                    text_content = self.driver.find_element(By.TAG_NAME, "body").text[:5000]
                    _save_debug("06_page_text.txt", text_content)
                    logger.info("Page text:\n%s", text_content[:500])
                except Exception:
                    pass

            logger.info("Total subjects scraped: %d", len(attendance))
            return {"success": True, "data": attendance, "message": f"Found {len(attendance)} subjects"}

        except Exception as exc:
            logger.exception("Error parsing attendance table")
            return {"success": False, "message": str(exc), "data": []}

    @staticmethod
    def _parse_attendance_cell(cell_text: str) -> Optional[dict]:
        """
        Parse a cell like '25/26 (96%)' or '25/26' into attended, total, percentage.
        Returns None if the cell doesn't match.
        """
        if not cell_text or "/" not in cell_text:
            return None

        # Pattern: "25/26 (96%)" or "25/26(96%)" or just "25/26"
        m = re.match(r'(\d+)\s*/\s*(\d+)\s*(?:\(?\s*(\d+\.?\d*)\s*%?\s*\)?)?', cell_text.strip())
        if not m:
            return None

        attended = int(m.group(1))
        total = int(m.group(2))
        if m.group(3):
            percentage = float(m.group(3))
        elif total > 0:
            percentage = round(attended / total * 100, 2)
        else:
            percentage = 0.0

        if total <= 0 or attended < 0:
            return None

        return {"attended": attended, "total": total, "percentage": round(percentage, 2)}

    def _regex_parse_page(self, page_source: str) -> list[dict]:
        """
        Fallback: find subject codes near attendance data in raw HTML.
        Look for patterns like: AMT302</th>...<td>25/26 (96%)</td>
        """
        results = []
        try:
            # Find subject code headers followed by data cells
            # Pattern in HTML: <th>AMT302</th> ... then in same-index <td>25/26 (96%)</td>
            code_pattern = re.compile(r'<t[hd][^>]*>\s*([A-Z]{2,5}\d{3,4}[A-Za-z]?)\s*</t[hd]>')
            data_pattern = re.compile(r'<td[^>]*>\s*(\d+/\d+\s*\(\d+%?\))\s*</td>')

            codes = code_pattern.findall(page_source)
            data_cells = data_pattern.findall(page_source)

            logger.info("Regex found %d codes, %d data cells", len(codes), len(data_cells))

            # Filter out non-subject codes (like reg numbers)
            skip_codes = {"SCT", "KTU"}
            subject_codes = [c for c in codes if not any(c.startswith(s) for s in skip_codes)]

            for i, code in enumerate(subject_codes):
                if i < len(data_cells):
                    parsed = ETLabScraper._parse_attendance_cell(data_cells[i])
                    if parsed:
                        results.append({
                            "subject_code": code,
                            "subject_name": code,
                            "hours_attended": parsed["attended"],
                            "total_hours": parsed["total"],
                            "percentage": parsed["percentage"],
                        })
        except Exception as e:
            logger.warning("Regex page parse error: %s", e)
        return results
    # ── Helpers ───────────────────────────────────────────────────────
    @staticmethod
    def _map_columns(headers: list[str]) -> Optional[dict]:
        """Try to map header labels to column indices."""
        m: dict[str, int] = {}
        for i, h in enumerate(headers):
            hl = h.lower().strip()
            if not hl:
                continue
            if any(k in hl for k in ("code", "sub code", "subject code", "sub.code")):
                m["code"] = i
            elif any(k in hl for k in ("subject", "name", "course", "sub name", "subject name")):
                m["name"] = i
            elif any(k in hl for k in (
                "attended", "present", "hours attended",
                "classes attended", "hrs attended",
            )):
                m["attended"] = i
            elif any(k in hl for k in (
                "total", "conducted", "total hours",
                "classes conducted", "hrs conducted", "total classes",
            )):
                m["total"] = i
            elif any(k in hl for k in ("percent", "%", "attendance %", "attendance%", "duty")):
                m["percentage"] = i

        if "attended" in m and "total" in m:
            return m

        # Fallback: look for generic "hour" / "class" / "period" headers
        for i, h in enumerate(headers):
            hl = h.lower().strip()
            if "hour" in hl or "class" in hl or "period" in hl:
                if "attended" not in m:
                    m["attended"] = i
                elif "total" not in m:
                    m["total"] = i

        if "attended" in m and "total" in m:
            return m
        return None

    @staticmethod
    def _parse_int(text: str) -> int:
        digits = "".join(c for c in text if c.isdigit())
        return int(digits) if digits else 0

    @staticmethod
    def _parse_float(text: str) -> float:
        cleaned = text.replace("%", "").strip()
        try:
            return round(float(cleaned), 2)
        except ValueError:
            return 0.0

    def _find_first(self, selectors, wait):
        for by, value in selectors:
            try:
                return wait.until(EC.presence_of_element_located((by, value)))
            except TimeoutException:
                continue
        return None

    def get_page_source(self) -> str:
        """Return current page source for debugging."""
        if self.driver:
            return self.driver.page_source
        return ""

    def get_current_url(self) -> str:
        """Return current URL for debugging."""
        if self.driver:
            return self.driver.current_url
        return ""

    def get_all_links(self) -> list[dict]:
        """Return all links on current page for debugging."""
        if not self.driver:
            return []
        links = []
        try:
            for a in self.driver.find_elements(By.TAG_NAME, "a"):
                try:
                    links.append({
                        "text": a.text.strip(),
                        "href": a.get_attribute("href") or "",
                    })
                except StaleElementReferenceException:
                    continue
        except Exception:
            pass
        return links
