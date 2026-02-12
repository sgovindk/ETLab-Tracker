"""
ETLab Attendance Tracker – REST API
====================================
FastAPI server that exposes Selenium-scraped attendance data.
Run:  python main.py   (starts on 0.0.0.0:8000)
"""

import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from scraper import ETLabScraper

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ── Global scraper instance ──────────────────────────────────────────
_scraper: ETLabScraper | None = None


@asynccontextmanager
async def lifespan(application: FastAPI):
    yield
    global _scraper
    if _scraper:
        _scraper.close()
        _scraper = None
        logger.info("Scraper shut down cleanly")


app = FastAPI(
    title="ETLab Attendance Tracker API",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Request / Response models ────────────────────────────────────────
class LoginRequest(BaseModel):
    username: str
    password: str


class SubjectData(BaseModel):
    subject_code: str
    subject_name: str
    hours_attended: int
    total_hours: int
    percentage: float


class AttendanceResponse(BaseModel):
    success: bool
    message: str = ""
    data: list[SubjectData] = []


# ── Endpoints ────────────────────────────────────────────────────────
@app.post("/api/login", response_model=dict)
async def login(req: LoginRequest):
    """Authenticate against ETLab and keep browser session alive."""
    global _scraper
    if _scraper:
        _scraper.close()

    _scraper = ETLabScraper()
    result = _scraper.login(req.username, req.password)

    if not result["success"]:
        _scraper.close()
        _scraper = None
        raise HTTPException(status_code=401, detail=result["message"])

    return result


@app.get("/api/attendance", response_model=AttendanceResponse)
async def get_attendance():
    """Scrape attendance data from the current browser session."""
    if not _scraper:
        raise HTTPException(status_code=401, detail="Not logged in. Call /api/login first.")

    result = _scraper.get_attendance()
    if not result["success"]:
        raise HTTPException(status_code=502, detail=result.get("message", "Scraping failed"))

    return result


@app.post("/api/fetch", response_model=AttendanceResponse)
async def fetch_attendance(req: LoginRequest):
    """One-shot: login → scrape → close browser. Best for mobile clients."""
    global _scraper
    if _scraper:
        _scraper.close()

    _scraper = ETLabScraper()

    login_result = _scraper.login(req.username, req.password)
    if not login_result["success"]:
        _scraper.close()
        _scraper = None
        raise HTTPException(status_code=401, detail=login_result["message"])

    attendance_result = _scraper.get_attendance()
    _scraper.close()
    _scraper = None

    if not attendance_result["success"]:
        raise HTTPException(
            status_code=502,
            detail=attendance_result.get("message", "Failed to scrape attendance"),
        )

    return attendance_result


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.get("/api/debug")
async def debug_info():
    """Return debug info: current URL, all links, and page text snippet."""
    if not _scraper:
        raise HTTPException(status_code=401, detail="Not logged in. Call /api/login first.")
    return {
        "current_url": _scraper.get_current_url(),
        "links": _scraper.get_all_links(),
        "page_text_snippet": _scraper.get_page_source()[:5000],
    }


# ── Entry-point ──────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
