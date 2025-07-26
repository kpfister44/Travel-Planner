-- basic schema for the app, encompassing user logins, destinations,
-- activities, attractions, and storing prompt data

-- Users (authentication)
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    hashed_password TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Destinations
CREATE TABLE destinations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    country TEXT,
    description TEXT,
    image_url TEXT
);

-- Activities
CREATE TABLE activities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    destination_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    FOREIGN KEY (destination_id) REFERENCES destinations(id)
);

-- Attractions
CREATE TABLE attractions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    destination_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    FOREIGN KEY (destination_id) REFERENCES destinations(id)
);

-- Prompts (logging inputs and outputs)
CREATE TABLE prompts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    input_text TEXT,
    llm_output TEXT,
    prompt_template TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
