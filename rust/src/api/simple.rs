use crate::database_impl::VaultDatabase;
use std::sync::OnceLock;
use rusqlite::params;

// Stores the globally accessible, initialized database instance
static VAULT_DB: OnceLock<VaultDatabase> = OnceLock::new();

#[flutter_rust_bridge::frb(sync)]
pub fn initialize_vault(db_path: String, encryption_key: String) -> Result<String, String> {
    // 1. Create database and apply encryption
    let db = VaultDatabase::new(&db_path, &encryption_key)
        .map_err(|e| format!("Failed to create database: {}", e))?;

    // 2. Run migrations
    let applied = db.run_migrations()
        .map_err(|e| format!("Migration failed: {}", e))?;

    // 3. Store globally for subsequent API calls
    VAULT_DB.set(db).map_err(|_| "Vault already initialized".to_string())?;

    Ok(format!("Vault initialized! Applied {} migrations", applied))
}

#[flutter_rust_bridge::frb(sync)]
pub fn save_memory(content: String) -> Result<i64, String> {
    let db = VAULT_DB.get().ok_or_else(|| "Vault not initialized".to_string())?;
    let conn = db.get_connection();
    let conn_guard = conn.lock().unwrap();

    let timestamp = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;

    conn_guard.execute(
        "INSERT INTO memory_entries (content, encrypted_data, tags, created_at, updated_at) VALUES (?1, ?2, ?3, ?4, ?5)",
        params![
            content,
            content.as_bytes(), // TODO: Encrypt this
            "",
            timestamp,
            timestamp
        ],
    ).map_err(|e| format!("Save failed: {}", e))?;

    Ok(conn_guard.last_insert_rowid())
}
// Add this struct for returning memory entries
#[derive(Debug, Clone)]
pub struct MemoryEntry {
    pub id: i64,
    pub content: String,
    pub tags: String,
    pub created_at: i64,
    pub updated_at: i64,
    pub accessed_count: i32,
}

// Get a single memory by ID
#[flutter_rust_bridge::frb(sync)]
pub fn get_memory(id: i64) -> Result<MemoryEntry, String> {
    let db = VAULT_DB.get().ok_or_else(|| "Vault not initialized".to_string())?;
    let conn = db.get_connection();
    let conn_guard = conn.lock().unwrap();

    let entry = conn_guard.query_row(
        "SELECT id, content, tags, created_at, updated_at, accessed_count 
         FROM memory_entries WHERE id = ?1",
        params![id],
        |row| {
            Ok(MemoryEntry {
                id: row.get(0)?,
                content: row.get(1)?,
                tags: row.get(2)?,
                created_at: row.get(3)?,
                updated_at: row.get(4)?,
                accessed_count: row.get(5)?,
            })
        },
    ).map_err(|e| format!("Failed to get memory: {}", e))?;

    // Update accessed count
    conn_guard.execute(
        "UPDATE memory_entries SET accessed_count = accessed_count + 1 WHERE id = ?1",
        params![id],
    ).map_err(|e| format!("Failed to update access count: {}", e))?;

    Ok(entry)
}

// List all memories (most recent first)
#[flutter_rust_bridge::frb(sync)]
pub fn list_memories() -> Result<Vec<MemoryEntry>, String> {
    let db = VAULT_DB.get().ok_or_else(|| "Vault not initialized".to_string())?;
    let conn = db.get_connection();
    let conn_guard = conn.lock().unwrap();

    let mut stmt = conn_guard
        .prepare("SELECT id, content, tags, created_at, updated_at, accessed_count 
                  FROM memory_entries ORDER BY created_at DESC")
        .map_err(|e| format!("Failed to prepare statement: {}", e))?;

    let entries = stmt
        .query_map([], |row| {
            Ok(MemoryEntry {
                id: row.get(0)?,
                content: row.get(1)?,
                tags: row.get(2)?,
                created_at: row.get(3)?,
                updated_at: row.get(4)?,
                accessed_count: row.get(5)?,
            })
        })
        .map_err(|e| format!("Query failed: {}", e))?
        .collect::<Result<Vec<_>, _>>()
        .map_err(|e| format!("Failed to collect results: {}", e))?;

    Ok(entries)
}

// Delete a memory
#[flutter_rust_bridge::frb(sync)]
pub fn delete_memory(id: i64) -> Result<String, String> {
    let db = VAULT_DB.get().ok_or_else(|| "Vault not initialized".to_string())?;
    let conn = db.get_connection();
    let conn_guard = conn.lock().unwrap();

    let rows_affected = conn_guard
        .execute("DELETE FROM memory_entries WHERE id = ?1", params![id])
        .map_err(|e| format!("Delete failed: {}", e))?;

    if rows_affected == 0 {
        Err("Memory not found".to_string())
    } else {
        Ok(format!("Deleted memory {}", id))
    }
}