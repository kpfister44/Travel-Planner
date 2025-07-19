# Travel Planner

A group learning project focused on building a travel planning app using LLM APIs (Anthropic/OpenAI). The app combines intelligent destination discovery with smart itinerary optimization.

## Project Structure

```
Travel-Planner/
├── backend/                 # Python FastAPI backend
├── frontend/               # iOS SwiftUI frontend
├── docs/                   # Project documentation
└── README.md              # This file
```

## Getting Started

### Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Frontend Setup
```bash
cd frontend/TravelPlanner
open TravelPlanner.xcodeproj
```

## Team
4 developers learning LLM API integration and full-stack development.

## Core Features
- Interactive preference questionnaire
- LLM-powered destination recommendations
- Smart itinerary optimization
- Export capabilities

## Technologies
- **Backend**: Python, FastAPI, SQLAlchemy, OpenAI/Anthropic APIs
- **Frontend**: iOS SwiftUI, Swift 5.9+
- **Database**: SQLite
- **External APIs**: Weather, Maps, LLM services
