<<<<<<< HEAD
pub mod api;
mod frb_generated; /* Auto-generated */
mod database;      // <--- This line allows your app to use the new database file
=======
// src/lib.rs

// --- Imports ---
use std::ffi::{CStr, CString}; 
use parking_lot::Mutex;
use lazy_static::lazy_static;

// Declare the database module
pub mod database; 
use database::DbHandle;

// --- Thread Safety Wrapper ---
// Wraps the raw pointer and manually asserts safety for global static use.
#[derive(Copy, Clone)]
pub struct FfiDbHandle(*mut DbHandle);

// SAFETY: Assert Send/Sync because the underlying data (VaultDb) 
// is protected by Arc<Mutex<...>> and the global static is protected 
// by parking_lot::Mutex.
unsafe impl Send for FfiDbHandle {}
unsafe impl Sync for FfiDbHandle {}

// --- Global State Management ---
// This is the SINGLE and CORRECT definition.
lazy_static! {
   static ref DB_HANDLE: Mutex<Option<FfiDbHandle>> = Mutex::new(None); 
}

// --- External Function Declarations ---
extern "C" {
    // We declare the signature of the function defined in src/database.rs
    pub fn vault_db_open(db_path: *const std::os::raw::c_char, key_ptr: *const std::os::raw::c_char) -> *mut DbHandle;
    // Add execute function declaration for later use
    pub fn vault_db_execute(handle: *mut DbHandle, sql_ptr: *const std::os::raw::c_char) -> i32;
}

// --- FFI Initialization Function ---

/// Initializes the Rust backend, including the database connection.
#[no_mangle]
pub extern "C" fn initialize_vault(db_file_path: *const std::os::raw::c_char) -> bool {
    
    // 1. Convert the C-string pointer received from Dart into a Rust String slice
    let db_path_c_str = unsafe {
        if db_file_path.is_null() {
            eprintln!("Initialization failed: Database path is null.");
            return false;
        }
        CStr::from_ptr(db_file_path)
    };

    let db_path_str = match db_path_c_str.to_str() {
        Ok(s) => s,
        Err(e) => {
            eprintln!("Initialization failed: Invalid UTF-8 sequence in path: {}", e);
            return false;
        }
    };
    
    // 2. Lock the global handle and attempt initialization
    let mut handle_guard = DB_HANDLE.lock();
    
    // Check if it has already been initialized (prevents double init)
    if handle_guard.is_some() {
        println!("Vault already initialized. Skipping.");
        return true;
    }
    
    let db_key = String::from("");

    // 3. Prepare C-Strings and Pointers for the FFI call
    let db_path_cstring = match CString::new(db_path_str) {
        Ok(s) => s,
        Err(_) => {
            eprintln!("Initialization failed: Database path contains null byte.");
            return false;
        }
    };
    let key_cstring = match CString::new(db_key) {
        Ok(s) => s,
        Err(_) => {
            eprintln!("Initialization failed: Encryption Key contains null byte.");
            return false;
        }
    };

    // 4. Perform the actual database initialization using the external function
    let db_handle_ptr = unsafe {
        vault_db_open(db_path_cstring.as_ptr(), key_cstring.as_ptr())
    };

    // 5. Check the result of the FFI call and store the handle
    if db_handle_ptr.is_null() {
        eprintln!("Database initialization failed via vault_db_open.");
        false
    } else {
        println!("Vault database initialized successfully! Path: {}", db_path_str);
        // CORRECT: Wrap the raw pointer in the thread-safe FfiDbHandle wrapper
        *handle_guard = Some(FfiDbHandle(db_handle_ptr)); 
        true
    }
}


// --- FFI Helper Function: Create Table ---

/// Runs a simple CREATE TABLE query to verify the connection.
/// Returns true on success, false on error.
#[no_mangle]
pub extern "C" fn vault_db_create_table() -> bool {
    // 1. Lock the global handle to get the FfiDbHandle wrapper
    let handle_guard = DB_HANDLE.lock();
    let handle_wrapper = match *handle_guard {
        Some(wrapper) => wrapper,
        None => {
            eprintln!("Error: Database not initialized before calling create table.");
            return false;
        }
    };
    // Extract the raw pointer
    let handle_ptr = handle_wrapper.0;


    // 2. Define the SQL and convert it to C-String
    let sql = "CREATE TABLE IF NOT EXISTS secrets (
        id INTEGER PRIMARY KEY,
        key TEXT NOT NULL UNIQUE,
        value BLOB NOT NULL
    )";

    let sql_cstring = match CString::new(sql) {
        Ok(s) => s,
        Err(_) => {
            eprintln!("Error: SQL statement contains null byte.");
            return false;
        }
    };

    // 3. Call the external execute function
    let result = unsafe {
        vault_db_execute(handle_ptr, sql_cstring.as_ptr())
    };

    result == 0 // Returns true if vault_db_execute returns 0 (success)
}
>>>>>>> 7cddacf (Description of the work I completed before pulling)
