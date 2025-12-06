// rust/src/database.rs
use rusqlite::{params, Connection, Result};

pub struct Database {
    conn: Connection,
}

impl Database {
    // 1. Open (or create) the database file
    pub fn open(path: String) -> Result<Self> {
        let conn = Connection::open(path)?;
        
        // 2. Create the table if it doesn't exist
        conn.execute(
            "CREATE TABLE IF NOT EXISTS memories (
                id INTEGER PRIMARY KEY,
                content TEXT NOT NULL,
                date_added TEXT NOT NULL
            )",
            [],
        )?;

        Ok(Database { conn })
    }

    // 3. Save a memory
    pub fn add_memory(&self, content: String) -> Result<()> {
        let date = "2025-12-06"; // Placeholder date for now
        self.conn.execute(
            "INSERT INTO memories (content, date_added) VALUES (?1, ?2)",
            params![content, date],
        )?;
        Ok(())
    }

    // 4. Read all memories (We will use this later)
    pub fn get_memories(&self) -> Result<Vec<String>> {
        let mut stmt = self.conn.prepare("SELECT content FROM memories ORDER BY id DESC")?;
        let rows = stmt.query_map([], |row| row.get(0))?;

        let mut results = Vec::new();
        for r in rows {
            results.push(r?);
        }
        Ok(results)
    }
}