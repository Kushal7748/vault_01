-- V2__add_favorites.sql
-- Add favorites feature

CREATE TABLE favorites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    memory_id INTEGER NOT NULL,
    added_at INTEGER NOT NULL,
    FOREIGN KEY (memory_id) REFERENCES memory_entries(id) ON DELETE CASCADE
);

CREATE INDEX idx_favorites_memory ON favorites(memory_id);
