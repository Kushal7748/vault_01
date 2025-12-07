// rust/src/database.rs

use rusqlite::{Connection, Result, params};
use parking_lot::Mutex;
use std::sync::Arc;
use std::path::Path;

/// The internal wrapper for the rusqlite connection, ensuring thread safety.
pub struct DbHandle {
    // We use parking_lot::Mutex for performance and protection against concurrent access.
    conn: Mutex<Connection>,
}

/// VaultDb: The primary handle exposed to src/lib.rs and the FFI layer.
/// It uses Arc<DbHandle> for shared, safe ownership across threads.
#[derive(Clone)]
pub struct VaultDb {
    handle: Arc<DbHandle>,
}

impl VaultDb {
    /// Initializes and opens the database connection, applying the SQLCipher key.
    pub fn new(db_path: &str, encryption_key: &str) -> Result<Self> {
        let path = Path::new(db_path);

        // 1. Open the connection
        let conn = Connection::open(path)?;

        // 2. Set the SQLCipher key immediately after opening
        let key_pragma = format!("PRAGMA key = '{}';", encryption_key);
        // Note: For security, use `PRAGMA key = X'hex_key'` in production
        conn.execute(&key_pragma, [])?;

        // 3. Initialize the DbHandle with the Mutex-wrapped connection
        let handle = DbHandle {
            conn: Mutex::new(conn),
        };

        // 4. Wrap the DbHandle in an Arc for shared, thread-safe ownership
        Ok(VaultDb {
            handle: Arc::new(handle),
        })
    }

    /// Executes the initial setup query (creating the 'memories' table).
    pub fn execute_initial_setup(&self) -> Result<()> {
        // Lock the Mutex to get exclusive access to the Connection
        let conn_lock = self.handle.conn.lock();
        
        conn_lock.execute(
            "CREATE TABLE IF NOT EXISTS memories (
                id INTEGER PRIMARY KEY,
                content TEXT NOT NULL,
                date_added TEXT NOT NULL
            );",
            [],
        )?;
        
        // Lock is released when conn_lock goes out of scope
        Ok(())
    }

    /// Example method: Save a memory (Placeholder date logic)
    pub fn add_memory(&self, content: String) -> Result<()> {
        let conn_lock = self.handle.conn.lock();
        let date = "2025-12-06"; // Placeholder
        
        conn_lock.execute(
            "INSERT INTO memories (content, date_added) VALUES (?1, ?2)",
            params![content, date],
        )?;
        
        Ok(())
    }
}