// src/rust/api/simple.rs (FRB Entry Point)

use crate::database::VaultDb;
use parking_lot::Mutex;
use lazy_static::lazy_static;

// --- Global State Management (The same as before, now in the FRB API file) ---
lazy_static! {
   // The Option<VaultDb> holds the single, thread-safe instance
   static ref DB_HANDLE: Mutex<Option<VaultDb>> = Mutex::new(None); 
}

/// Initializes the Vault database, applying the encryption key and setting up tables.
/// 
/// This is the FRB public function called from Dart.
pub async fn init_db(db_file_path: String, encryption_key: String) -> Result<(), String> {
    
    // 1. Check for double initialization
    let mut handle_guard = DB_HANDLE.lock();
    if handle_guard.is_some() {
        println!("Vault already initialized. Skipping.");
        return Ok(());
    }

    // 2. Initialize the thread-safe connection using the core logic
    match VaultDb::new(&db_file_path, &encryption_key) {
        Ok(db) => {
            println!("Vault database initialized successfully!");
            
            // 3. Run the initial table setup
            match db.execute_initial_setup() {
                Ok(_) => {
                    // Store the handle only after successful setup
                    *handle_guard = Some(db); 
                    Ok(())
                }
                Err(e) => {
                    Err(format!("Table creation failed: {:?}", e))
                }
            }
        }
        Err(e) => {
            Err(format!("Database initialization failed: {:?}", e))
        }
    }
}