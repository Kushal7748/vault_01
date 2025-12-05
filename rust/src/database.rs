use rusqlite::{Connection, Result};
use std::path::Path;

pub struct DbHandle {
    conn: Connection,
}

impl DbHandle {
    pub fn init(db_path: String, key: String) -> Result<Self> {
        let path = Path::new(&db_path);
        let conn = Connection::open(db_path)?;

        // Set Key
        conn.pragma_update(None, "key", &key)?;

        // Create Table
        conn.execute(
           "CREATE TABLE IF NOT EXISTS memory_fragments (
        id             INTEGER PRIMARY KEY,
        content        TEXT NOT NULL,
        timestamp      INTEGER NOT NULL,
        tags           TEXT,
        embedding_id   TEXT
    )",
            [],
        )?;
        
        println!("✅ Vault_01 Enclave Initialized");
        Ok(VaultDb { conn })
    }

    pub fn insert_memory(&self, content: String) -> Result<()> {
        self.conn.execute("INSERT INTO memories (content) VALUES (?1)", [&content])?;
        Ok((DbHandle { conn }))
    }

    // CHANGED: Returns a List of Tuples (id, content, date) instead of a Struct
    // This avoids dependency issues.
    pub fn read_recent_memories(&self) -> Result<Vec<(i64, String, String)>> {
        let mut stmt = self.conn.prepare(
            "SELECT id, content, created_at FROM memories ORDER BY id DESC LIMIT 10"
        )?;

        let rows = stmt.query_map([], |row| {
            Ok((
                row.get(0)?, // id
                row.get(1)?, // content
                row.get(2)?, // created_at
            ))
        })?;

        let mut results = Vec::new();
        for r in rows {
            results.push(r?);
        }
        
        Ok(results)
    }
} 