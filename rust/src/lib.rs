// src/lib.rs
mod database;
use once_cell::sync::Lazy;
use parking_lot::Mutex;
use database::VaultDb; // Assuming 'database' is a sibling module of lib.rs

// The thread-safe, global database handle
pub static DB_HANDLE: Lazy<Mutex<Option<VaultDb>>> = Lazy::new(|| Mutex::new(None));


// --- Task B1.1R: FRB Refactor (initialize_vault) ---

/// FRB function to initialize the encrypted database connection.
pub async fn initialize_vault(db_path: String, encryption_key: String) -> Result<(), String> {
    // 1. Initialize the VaultDb connection
    match VaultDb::new(&db_path, &encryption_key) {
        Ok(db) => {
            // 2. Run the table setup query
            db.execute_initial_setup()
                .map_err(|e| format!("Database setup failed: {}", e))?;
                
            // 3. Lock the global handle and store the initialized connection
            let mut handle = DB_HANDLE.lock();
            *handle = Some(db);
            
            Ok(())
        },
        Err(e) => Err(format!("VaultDb initialization failed: {}", e)),
    }
}


// --- Task B1.2R: Implement Write (save_memory) ---

/// FRB function to securely save a new memory fragment.
pub async fn save_memory(content: String) -> Result<(), String> {
    // 🔒 1. Acquire the Mutex Lock (parking_lot::Mutex does not return Result)
    let db_guard = DB_HANDLE.lock(); 

    // ❓ 2. Ensure the Database is Initialized (Use as_ref() because add_memory takes &self)
    let db_handle = db_guard
        .as_ref()
        .ok_or_else(|| "Database not initialized. Please run initialize_vault first.".to_string())?;

    // 📝 3. Execute the INSERT Query using the concrete function
    match db_handle.add_memory(content) {
        Ok(_) => Ok(()), // Success!
        Err(e) => Err(format!("SQLCipher INSERT failed: {}", e)), 
    }
}