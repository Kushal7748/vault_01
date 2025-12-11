// src/rust/api/simple.rs

use crate::database::VaultDb;
use crate::DB_HANDLE;

/// FRB function to initialize the encrypted database connection.
pub fn initialize_vault(db_path: String, encryption_key: String) -> Result<(), String> {
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

/// FRB function to securely save a new memory fragment.
pub fn save_memory(content: String) -> Result<(), String> {
    // 🔒 1. Acquire the Mutex Lock
    let db_guard = DB_HANDLE.lock(); 
    
    // ❓ 2. Ensure the Database is Initialized
    let db_handle = db_guard
        .as_ref()
        .ok_or_else(|| "Database not initialized. Please run initialize_vault first.".to_string())?;
    
    // 📝 3. Execute the INSERT Query
    match db_handle.add_memory(content) {
        Ok(_) => Ok(()),
        Err(e) => Err(format!("SQLCipher INSERT failed: {}", e)), 
    }
}