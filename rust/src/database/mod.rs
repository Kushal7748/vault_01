use anyhow::Result;
use refinery::embed_migrations;
use rusqlite::{Connection, OpenFlags};
use std::sync::{Arc, Mutex};

embed_migrations!("migrations");

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
        let mut conn = self.conn.lock().unwrap();
        let report = migrations::runner().run(&mut *conn)?;
        Ok(report.applied_migrations().len() as i32)
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
}
