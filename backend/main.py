# FastAPI app entry point
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.endpoints import destination_rounter, itinerary_router
from app.core.logging_config import setup_logging
import logging


setup_logging()
logger = logging.getLogger(__name__)

app = FastAPI()

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development; adjust in production
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

# Include the API router
app.include_router(destination_rounter.router)
app.include_router(itinerary_router.router)


# Define the root endpoint
@app.get("/")
async def root():
    logger.info("Health check: Traveler-Planner API is running")
    return {"message": "Health check: Traveler-Planner API is running"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=8002, reload=True)
