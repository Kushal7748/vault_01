// rust/src/api/simple.rs
use crate::database::Database;
use std::sync::Mutex;
use once_cell::sync::Lazy; // Helper to keep DB open

// Global Database Connection (Thread-safe)
static DB: Lazy<Mutex<Option<Database>>> = Lazy::new(|| Mutex::new(None));

// 1. Initialize the Database (Flutter calls this when app starts)
pub fn init_db(app_doc_dir: String) -> String {
    let db_path = format!("{}/vault.db", app_doc_dir);
    
    match Database::open(db_path.clone()) {
        Ok(db) => {
            let mut global_db = DB.lock().unwrap();
            *global_db = Some(db);
            format!("Database ready at: {}", db_path)
        }
        Err(e) => format!("Database Init Failed: {}", e),
    }
}

// 2. Save Memory (Flutter calls this when you click button)
pub fn save_memory(content: String) -> String {
    let global_db = DB.lock().unwrap();
    
    if let Some(db) = &*global_db {
        match db.add_memory(content) {
            Ok(_) => "Success! Memory saved to Disk.".to_string(),
            Err(e) => format!("Failed to save: {}", e),
        }
    } else {
        "Error: Database not initialized!".to_string()
    }
}