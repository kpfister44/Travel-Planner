-- basic schema for the app, to save questionnaire and associated activities

-- Questionnaires (stores the questionnaire data and destination info)
CREATE TABLE questionnaires (
    id TEXT PRIMARY KEY, 
    destination_id INTEGER,
    destination_name TEXT NOT NULL,
    ready_for_optimization BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Activities (stores the LLM-suggested activities for each questionnaire)
CREATE TABLE activities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    questionnaire_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    duration_hours REAL,
    cost REAL,
    priority TEXT DEFAULT 'medium',  
    FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE
);