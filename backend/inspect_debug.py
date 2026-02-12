"""Inspect the debug HTML files to understand the page structure."""
import re
import os

debug_dir = os.path.join(os.path.dirname(__file__), "debug")

for fname in ["03_student_attendance.html", "05_final_attendance_page.html"]:
    fpath = os.path.join(debug_dir, fname)
    if not os.path.exists(fpath):
        print(f"File not found: {fname}")
        continue

    html = open(fpath, encoding="utf-8").read()
    print(f"\n{'='*60}")
    print(f"FILE: {fname}")
    print(f"{'='*60}")

    # Find links with "attendance" in href
    links = re.findall(r'href="([^"]*attendance[^"]*)"', html, re.IGNORECASE)
    print(f"\nAttendance links found: {len(links)}")
    for l in sorted(set(links)):
        print(f"  {l}")

    # Find links with "viewattendancesubject" in href
    links2 = re.findall(r'href="([^"]*viewattendancesubject[^"]*)"', html, re.IGNORECASE)
    print(f"\nViewAttendanceSubject links: {len(links2)}")
    for l in sorted(set(links2)):
        print(f"  {l}")

    # Find all tab/nav links (the tabs at top: Attendance, By Month, By Subject, etc.)
    tabs = re.findall(r'<a[^>]*href="([^"]*)"[^>]*>\s*(Attendance[^<]*|By[^<]*|Credit[^<]*|View[^<]*)</a>', html, re.IGNORECASE)
    print(f"\nTab/nav links:")
    for href, text in tabs:
        print(f"  '{text.strip()}' -> {href}")

    # Check page title/heading
    titles = re.findall(r'<title[^>]*>(.*?)</title>', html, re.DOTALL)
    h1s = re.findall(r'<h[1-3][^>]*>(.*?)</h[1-3]>', html, re.DOTALL)
    breadcrumb = re.findall(r'class="[^"]*breadcrumb[^"]*"[^>]*>(.*?)</(?:ul|div|ol)>', html, re.DOTALL)

    print(f"\nTitle: {[re.sub(r'<[^>]+>', '', t).strip() for t in titles]}")
    if h1s:
        print(f"Headings: {[re.sub(r'<[^>]+>', '', h).strip() for h in h1s[:5]]}")

    # Check current URL from page
    url_match = re.search(r'(sctce\.etlab\.in/[^"<\s]+)', html)
    if url_match:
        print(f"URL in page: {url_match.group(1)}")
