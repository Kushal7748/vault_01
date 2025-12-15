-- V1__initial_schema.sql

CREATE TABLE vault_metadata (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    created_at INTEGER NOT NULL,
    last_accessed INTEGER NOT NULL,
    version TEXT NOT NULL,
    key_derivation_salt BLOB NOT NULL
);

CREATE TABLE memory_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL,
    encrypted_data BLOB NOT NULL,
    tags TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    accessed_count INTEGER DEFAULT 0
);

CREATE INDEX idx_memory_created ON memory_entries(created_at DESC);
CREATE INDEX idx_memory_updated ON memory_entries(updated_at DESC);
