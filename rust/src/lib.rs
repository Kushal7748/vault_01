mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
// src/lib.rs

// --- Imports ---
use std::ffi::{CStr, CString};
use parking_lot::Mutex;
use lazy_static::lazy_static;
use std::os::raw::c_char;

// Declare and use the database module
pub mod database;
use database::VaultDb; // <-- Corrected import to use the public struct

// --- Global State Management ---
// The VaultDb is safe to store here because it uses Arc<Mutex<...>> internally.
lazy_static! {
   static ref DB_HANDLE: Mutex<Option<VaultDb>> = Mutex::new(None); 
}

// --- FFI Initialization Function ---

/// Initializes the Rust backend and opens the encrypted database connection.
/// 
/// Returns 0 on success, a non-zero error code on failure.
#[no_mangle]
pub extern "C" fn initialize_vault(
    db_file_path: *const c_char, 
    encryption_key: *const c_char // <-- MUST accept the key from Dart/Flutter
) -> i32 { // Returning i32 for error code (0 = success)

    // 1. Convert C-strings to Rust & Handle null pointers
    let db_path = match unsafe { CStr::from_ptr(db_file_path).to_str() } {
        Ok(s) => s,
        Err(_) => { eprintln!("Error: Invalid UTF-8 sequence in database path."); return 1; }
    };
    
    let key = match unsafe { CStr::from_ptr(encryption_key).to_str() } {
        Ok(s) => s,
        Err(_) => { eprintln!("Error: Invalid UTF-8 sequence in encryption key."); return 2; }
    };

    // 2. Lock the global handle
    let mut handle_guard = DB_HANDLE.lock();
    
    // Check for double initialization
    if handle_guard.is_some() {
        println!("Vault already initialized. Path: {}", db_path);
        return 0;
    }
    
    // 3. Call the VaultDb::new method directly
    match VaultDb::new(db_path, key) {
        Ok(db) => {
            println!("Vault database initialized successfully! Path: {}", db_path);
            *handle_guard = Some(db);
            0 // Success
        }
        Err(e) => {
            eprintln!("Database initialization failed: {:?}", e);
            3 // Database error code
        }
    }
}


// --- FFI Helper Function: Create Table ---

/// Runs a simple CREATE TABLE query to verify the connection.
/// Returns 0 on success, non-zero on error.
#[no_mangle]
pub extern "C" fn vault_db_create_table() -> i32 { // Returning i32 for error code
    
    // 1. Lock the global handle and ensure it's initialized
    let handle_guard = DB_HANDLE.lock();
    let db = match handle_guard.as_ref() {
        Some(db) => db,
        None => {
            eprintln!("Error: Database not initialized before calling create table.");
            return 10; // Initialization error
        }
    };

    // 2. Call the method defined on the VaultDb struct
    match db.execute_initial_setup() { // Assuming you defined this method on VaultDb
        Ok(_) => {
            println!("Initial table created successfully.");
            0 // Success
        }
        Err(e) => {
            eprintln!("Database execution failed: {:?}", e);
            11 // Execution error
        }
    }
}

// NOTE: You will need to clean up your Dart side to ensure it passes the encryption key.