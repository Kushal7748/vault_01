use crate::database::VaultDb;
use std::sync::Mutex;

// --- 1. DEFINE STRUCT HERE (Best for Bridge) ---
pub struct Memory {
    pub id: i64,
    pub content: String,
    pub created_at: String,
}

// --- GLOBAL STATE ---
static DB: Mutex<Option<VaultDb>> = Mutex::new(None);

// --- FLUTTER API ---

pub fn init_database(path: String, key: String) -> String {
    match VaultDb::init(path, key) {
        Ok(db) => {
            let mut global_db = DB.lock().unwrap();
            *global_db = Some(db);
            "Success".to_string()
        }
        Err(e) => format!("Error: {}", e),
    }
}

pub fn insert_memory(content: String) -> String {
    let global_db = DB.lock().unwrap();
    if let Some(db) = &*global_db {
        match db.insert_memory(content) {
            Ok(_) => "Success".to_string(),
            Err(e) => format!("Database Error: {}", e),
        }
    } else {
        "Error: Database is not initialized!".to_string()
    }
}

pub fn read_memories() -> Vec<Memory> {
    let global_db = DB.lock().unwrap();
    if let Some(db) = &*global_db {
        // We get raw tuples from DB, then convert to Memory struct here
        match db.read_recent_memories() {
            Ok(raw_data) => {
                raw_data.into_iter().map(|(id, content, created_at)| Memory {
                    id,
                    content,
                    created_at
                }).collect()
            },
            Err(_) => Vec::new(), 
        }
    } else {
        Vec::new()
    }
}