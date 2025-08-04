-- basic schema for the app, to save questionnaire and associated activities

-- Questionnaires (stores the questionnaire data and destination info)
CREATE TABLE questionnaires (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    destination_id INTEGER,
    destination_name TEXT NOT NULL,
    ready_for_optimization BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Activities (stores the LLM-suggested activities for each questionnaire)
CREATE TABLE activities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    questionnaire_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    duration_hours REAL,
    cost REAL,
    priority TEXT DEFAULT 'medium',  
    FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE
);

-- Rate Limits table for API rate limiting
CREATE TABLE rate_limits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ip_address TEXT NOT NULL,
    request_count INTEGER DEFAULT 1,
    window_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_request TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);