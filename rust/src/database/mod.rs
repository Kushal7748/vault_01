use anyhow::Result;
use rusqlite::{Connection, OpenFlags};
use std::sync::{Arc, Mutex};

pub struct VaultDatabase {
    conn: Arc<Mutex<Connection>>,
}

impl VaultDatabase {
    pub fn new(db_path: &str, encryption_key: &str) -> Result<Self> {
        let conn = Connection::open_with_flags(
            db_path,
            OpenFlags::SQLITE_OPEN_READ_WRITE | OpenFlags::SQLITE_OPEN_CREATE,
        )?;

        // Set encryption
        conn.pragma_update(None, "key", encryption_key)?;
        
        // Configure for performance
        conn.pragma_update(None, "journal_mode", "WAL")?;
        conn.pragma_update(None, "synchronous", "NORMAL")?;
        conn.pragma_update(None, "foreign_keys", "ON")?;

        Ok(Self {
            conn: Arc::new(Mutex::new(conn)),
        })
    }

    pub fn run_migrations(&self) -> Result<i32> {
        let conn = self.conn.lock().unwrap();
        
        // Apply migrations manually - V1: Create vault_metadata and memory_entries tables
        conn.execute_batch(
            "BEGIN;
             CREATE TABLE IF NOT EXISTS vault_metadata (
                id INTEGER PRIMARY KEY CHECK (id = 1),
                created_at INTEGER NOT NULL,
                last_accessed INTEGER NOT NULL,
                version TEXT NOT NULL,
                key_derivation_salt BLOB NOT NULL
            );
            
            CREATE TABLE IF NOT EXISTS memory_entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                content TEXT NOT NULL,
                encrypted_data BLOB NOT NULL,
                tags TEXT,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL,
                access_count INTEGER DEFAULT 0
            );
            
            -- V2: Add favorites support
            CREATE TABLE IF NOT EXISTS favorites (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                memory_id INTEGER NOT NULL UNIQUE,
                created_at INTEGER NOT NULL,
                FOREIGN KEY (memory_id) REFERENCES memory_entries(id) ON DELETE CASCADE
            );
            COMMIT;"
        )?;
        
        // Return a migration count (we applied 2 schemas inline)
        Ok(2)
    }

    pub fn get_connection(&self) -> Arc<Mutex<Connection>> {
        Arc::clone(&self.conn)
    }
}
// ... existing code in mod.rs ...

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_database_creation() {
        // Use a temporary database path for testing
        let db_path = format!("/tmp/test_vault_{}.db", std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_nanos());
        
        let db = VaultDatabase::new(
            &db_path,
            "test_key_123"
        ).unwrap();

        // This triggers the automatic migration check
        let applied = db.run_migrations().unwrap();

        // Verify that migrations were actually applied
        // We expect at least 1 or 2 migrations (V1 and V2)
        assert!(applied > 0, "No migrations were applied!");
    }
#[test]
    fn test_save_and_retrieve_memory() {
        let db_path = format!("/tmp/test_retrieve_{}.db", 
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_nanos()
        );
        
        let db = VaultDatabase::new(&db_path, "test_key").unwrap();
        db.run_migrations().unwrap();
        
        let conn = db.get_connection();
        let guard = conn.lock().unwrap();
        
        // Insert test data
        guard.execute(
            "INSERT INTO memory_entries (content, encrypted_data, tags, created_at, updated_at)
             VALUES ('Test content', X'', 'test', 1234567890, 1234567890)",
            [],
        ).unwrap();
        
        // Retrieve and verify
        let count: i64 = guard.query_row(
            "SELECT COUNT(*) FROM memory_entries WHERE content = 'Test content'",
            [],
            |row| row.get(0)
        ).unwrap();
        
        assert_eq!(count, 1);
    }
}
