# Travel Planner API Contracts

## User Flow
1. **Initial Questionnaire** → User provides travel preferences
2. **Destination Recommendations** → LLM generates 3 destinations 
3. **Itinerary Questionnaire** → User selects destination + provides activity preferences
4. **Itinerary Generation** → LLM creates optimized daily schedule

## Base URL
```
Development: http://localhost:8000/api/v1
```

---

## 1. Destination Recommendations

### POST `/destinations/recommendations`

#### Request
```json
{
  "preferences": {
    "budget": {
      "min": 500,
      "max": 2000,
      "currency": "USD"
    },
    "travel_dates": {
      "start_date": "2024-07-15",
      "end_date": "2024-07-22"
    },
    "group_size": 2,
    "interests": [
      "cultural_experiences",
      "food_and_drink", 
      "outdoor_activities",
      "historical_sites"
    ],
    "travel_style": "balanced",
    "must_haves": ["walkable city", "good food scene"],
    "deal_breakers": ["extreme weather"]
  }
}
```

#### Response
```json
{
  "errors": [
    {
      "code": "string",
      "message": "string"
    }
  ],
  "recommendations": [
    {
      "id": "dest_001",
      "name": "Barcelona, Spain",
      "country": "Spain",
      "match_score": 92,
      "estimated_cost": 1650,
      "highlights": [
        "Stunning Gaudí architecture",
        "World-class food scene",
        "Beautiful beaches within city"
      ],
      "why_recommended": "Perfect for cultural interests with great walkability...",
      "image_url": "https://example.com/barcelona.jpg"
    },
    {
      "id": "dest_002", 
      "name": "Prague, Czech Republic",
      "country": "Czech Republic",
      "match_score": 88,
      "estimated_cost": 1200,
      "highlights": [
        "Medieval Old Town",
        "Affordable prices",
        "Rich history"
      ],
      "why_recommended": "Great value destination with amazing architecture...",
      "image_url": "https://example.com/prague.jpg"
    },
    {
      "id": "dest_003",
      "name": "Lisbon, Portugal", 
      "country": "Portugal",
      "match_score": 85,
      "estimated_cost": 1400,
      "highlights": [
        "Colorful neighborhoods",
        "Excellent seafood",
        "Mild climate"
      ],
      "why_recommended": "Charming coastal city with great food culture...",
      "image_url": "https://example.com/lisbon.jpg"
    }
  ]
}
```

---

## 2. Itinerary Questionnaire

### POST `/itinerary/questionnaire`

#### Request
```json
{
  "selected_destination": {
    "id": "dest_001",
    "name": "Barcelona, Spain"
  },
  "travel_dates": {
    "start_date": "2024-07-15",
    "end_date": "2024-07-22"
  },
  "activity_preferences": {
    "pace": "moderate",
    "daily_start_time": "09:00",
    "daily_end_time": "22:00",
    "max_activities_per_day": 4,
    "priority_interests": [
      "architecture",
      "food_experiences",
      "local_culture"
    ],
    "must_see_attractions": [
      "Sagrada Familia",
      "Park Güell",
      "Las Ramblas"
    ],
    "activity_types": {
      "cultural": "high",
      "outdoor": "medium", 
      "food": "high",
      "nightlife": "low",
      "shopping": "low"
    },
    "meal_preferences": {
      "breakfast": "hotel",
      "lunch": "local_restaurant",
      "dinner": "local_restaurant"
    },
    "transportation": "walking_and_public",
    "accommodation_area": "city_center"
  }
}
```

#### Response
```json
{
  "errors": [
    {
      "code": "string",
      "message": "string"
    }
  ],
  "questionnaire_id": "quest_001",
  "destination": {
    "id": "dest_001",
    "name": "Barcelona, Spain"
  },
  "suggested_activities": [
    {
      "id": "act_001",
      "name": "Sagrada Familia",
      "category": "cultural",
      "duration_hours": 2,
      "cost": 26,
      "priority": "high",
      "description": "Iconic basilica by Gaudí"
    },
    {
      "id": "act_002", 
      "name": "Park Güell",
      "category": "outdoor",
      "duration_hours": 2,
      "cost": 10,
      "priority": "high",
      "description": "Colorful park with city views"
    },
    {
      "id": "act_003",
      "name": "Tapas Walking Tour",
      "category": "food",
      "duration_hours": 3,
      "cost": 65,
      "priority": "medium",
      "description": "Guided food tour in Gothic Quarter"
    }
  ],
  "ready_for_optimization": true
}
```

---

## 3. Itinerary Generation

### POST `/itinerary/generate`

#### Request
```json
{
  "questionnaire_id": "quest_001",
  "selected_activities": [
    {
      "id": "act_001",
      "priority": "high"
    },
    {
      "id": "act_002", 
      "priority": "high"
    },
    {
      "id": "act_003",
      "priority": "medium"
    }
  ],
  "preferences": {
    "pace": "moderate",
    "daily_start_time": "09:00",
    "daily_end_time": "22:00",
    "max_activities_per_day": 4
  }
}
```

#### Response
```json
{
  "errors": [
    {
      "code": "string",
      "message": "string"
    }
  ],
  "itinerary": {
    "destination": "Barcelona, Spain",
    "total_days": 7,
    "daily_schedules": [
      {
        "date": "2024-07-15",
        "day_number": 1,
        "theme": "Arrival & Gothic Quarter",
        "activities": [
          {
            "start_time": "14:00",
            "end_time": "15:00",
            "activity": {
              "name": "Hotel Check-in",
              "type": "logistics",
              "notes": "Relax after arrival"
            }
          },
          {
            "start_time": "15:30",
            "end_time": "17:30",
            "activity": {
              "name": "Las Ramblas Walk",
              "type": "cultural",
              "notes": "Introduction to the city"
            }
          },
          {
            "start_time": "18:00",
            "end_time": "19:30",
            "activity": {
              "name": "Dinner at El Xampanyet",
              "type": "dining",
              "notes": "Traditional tapas experience"
            }
          }
        ],
        "daily_cost": 85,
        "walking_distance": "3.2 km"
      }
    ]
  },
  "summary": {
    "total_cost": 1650,
    "total_activities": 18,
    "optimization_score": 0.91
  }
}
```

---

## Data Types

### UserPreferences
```json
{
  "budget": {
    "min": 500,
    "max": 2000,
    "currency": "USD"
  },
  "travel_dates": {
    "start_date": "2024-07-15",
    "end_date": "2024-07-22"
  },
  "group_size": 2,
  "interests": ["cultural_experiences", "food_and_drink"],
  "travel_style": "balanced",
  "must_haves": ["walkable city"],
  "deal_breakers": ["extreme weather"]
}
```

### Destination
```json
{
  "id": "dest_001",
  "name": "Barcelona, Spain",
  "country": "Spain",
  "match_score": 92,
  "estimated_cost": 1650,
  "highlights": ["Gaudí architecture", "Food scene"],
  "why_recommended": "Perfect for cultural interests...",
  "image_url": "https://example.com/barcelona.jpg"
}
```

### Activity
```json
{
  "id": "act_001",
  "name": "Sagrada Familia",
  "category": "cultural",
  "duration_hours": 2,
  "cost": 26,
  "priority": "high",
  "description": "Iconic basilica by Gaudí"
}
```

### DailySchedule
```json
{
  "date": "2024-07-15",
  "day_number": 1,
  "theme": "Arrival & Gothic Quarter",
  "activities": [
    {
      "start_time": "14:00",
      "end_time": "15:00",
      "activity": {
        "name": "Hotel Check-in",
        "type": "logistics",
        "notes": "Relax after arrival"
      }
    }
  ],
  "daily_cost": 85,
  "walking_distance": "3.2 km"
}
```