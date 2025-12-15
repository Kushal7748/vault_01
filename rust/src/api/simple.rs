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
