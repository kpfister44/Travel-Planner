# Frontend-Backend API Integration

## Overview
This document describes the frontend-backend integration implemented for the Travel Planner app.

## Implementation Status

### ✅ Completed
- **APIService.swift**: Complete API service with authentication
- **Config.swift**: Centralized configuration management
- **QuestionnaireCoordinator**: Updated to use real API calls
- **Error Handling**: Comprehensive error handling for auth and API errors
- **Request Mapping**: UserPreferences mapped to backend request format

### 🔄 Integration Points

#### Destination Recommendations
- **Frontend**: `QuestionnaireCoordinator.loadDestinations()`
- **Backend**: `POST /destinations/recommendations`
- **Status**: ✅ Fully integrated
- **Authentication**: x-api-key header required

#### Future Integration (Mock Data Still Used)
- **Itinerary Activities**: `/itinerary/questionnaire` (partially implemented backend)
- **Itinerary Generation**: `/itinerary/generate` (placeholder backend)

## Configuration

### API Settings
- **Development**: `http://127.0.0.1:8001`
- **API Key**: `test_api_key` (configured in Config.swift)
- **Authentication**: x-api-key header

### Error Handling
The app handles multiple error scenarios:
- **Network errors**: Connection issues, timeouts
- **Authentication errors**: Invalid API key (401/403)
- **Validation errors**: Bad request data (400)
- **Server errors**: Backend issues (500+)

## Testing

### Prerequisites
1. Backend server running on `http://127.0.0.1:8001`
2. Valid API key configured
3. Backend `/destinations/recommendations` endpoint functional

### Test Steps
1. Complete questionnaire flow in iOS app
2. Reach destination selection step
3. Verify real destinations load (not mock data)
4. Test error scenarios (invalid API key, network issues)

## Data Mapping

### UserPreferences → DestinationRequest
The frontend UserPreferences model is mapped to the backend DestinationRequest format:

```swift
// Frontend model
UserPreferences {
    travelerInfo: TravelerInfo
    travelDates: TravelDates
    preferredLocation: String
    budget: Budget
    likes: [String]
    travelStyle: String
    mustHaves: [String]
    dislikes: [String]
    dealBreakers: [String]
}

// Backend request format
DestinationRequest {
    preferences: BackendUserPreferences {
        travelerInfo: BackendTravelerInfo
        travelDates: BackendTravelDates
        preferredLocation: BackendPreferredLocation
        budget: BackendBudget
        interests: [String]
        travelStyle: [String]
        mustHaves: [String]
        dealBreakers: [String]
    }
}
```

## Files Modified

### New Files
- `Services/APIService.swift` - Main API service
- `Utils/Config.swift` - Configuration management
- `frontend/API_INTEGRATION.md` - This documentation

### Modified Files
- `QuestionnaireCoordinator.swift` - Updated loadDestinations() method

## Next Steps
1. Test integration with running backend
2. Implement itinerary API integration when backend is ready
3. Add more robust error handling and retry logic
4. Move API key to secure storage