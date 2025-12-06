mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
// src/lib.rs

use std::path::Path;
use parking_lot::Mutex;
use lazy_static::lazy_static;

// Declare the database module you just created
pub mod database; 
use database::DbHandle;

// --- Global State Management ---
// We use a global static variable wrapped in an Option and Mutex.
// This allows the DbHandle to be initialized once and accessed safely 
// by all subsequent FFI calls from the Flutter application.

// Option<DbHandle>: It's wrapped in Option because it starts as None (uninitialized).
// Mutex: It uses a thread-safe lock to prevent multiple threads (or FFI calls)
// from accessing the connection simultaneously, which is crucial for SQLite.
lazy_static! {
    static ref DB_HANDLE: Mutex<Option<DbHandle>> = Mutex::new(None);
}


// --- FFI Initialization Function ---

/// Initializes the Rust backend, including the database connection.
/// 
/// This function is called once from the Flutter application at startup.
/// 
/// # Arguments
/// * `db_file_path` - The absolute path to the SQLite file.
/// 
/// # Returns
/// `true` on successful initialization, `false` otherwise.
#[no_mangle] // Essential FFI marker for C/Dart interop
pub extern "C" fn initialize_vault(db_file_path: *const std::os::raw::c_char) -> bool {
    
    // 1. Convert the C-string pointer received from Dart into a Rust String slice
    let db_path_c_str = unsafe {
        if db_file_path.is_null() {
            eprintln!("Initialization failed: Database path is null.");
            return false;
        }
        std::ffi::CStr::from_ptr(db_file_path)
    };

    let db_path_str = match db_path_c_str.to_str() {
        Ok(s) => s,
        Err(e) => {
            eprintln!("Initialization failed: Invalid UTF-8 sequence in path: {}", e);
            return false;
        }
    };
    
    let path = Path::new(db_path_str);
    
    // 2. Lock the global handle and attempt initialization
    let mut handle_guard = DB_HANDLE.lock();
    
    // Check if it has already been initialized (prevents double init)
    if handle_guard.is_some() {
        println!("Vault already initialized. Skipping.");
        return true;
    }
let db_key = String::from("");
    // 3. Perform the actual database initialization
    match DbHandle::init(path.to_string_lossy().to_string(), db_key) {
        Ok(handle) => {
            println!("Vault database initialized successfully! Path: {}", db_path_str);
            // Store the handle in the global static variable
            *handle_guard = Some(handle);
            true
        },
        Err(e) => {
            eprintln!("Database initialization failed: {}", e);
            // On failure, the global handle remains None
            false
        }
    }
}