<<<<<<< HEAD
// rust/src/database.rs
use rusqlite::{params, Connection, Result};

pub struct Database {
    conn: Connection,
}

impl Database {
    // 1. Open (or create) the database file
    pub fn open(path: String) -> Result<Self> {
        let conn = Connection::open(path)?;
        
        // 2. Create the table if it doesn't exist
        conn.execute(
            "CREATE TABLE IF NOT EXISTS memories (
                id INTEGER PRIMARY KEY,
                content TEXT NOT NULL,
                date_added TEXT NOT NULL
            )",
            [],
        )?;

        Ok(Database { conn })
    }

    // 3. Save a memory
    pub fn add_memory(&self, content: String) -> Result<()> {
        let date = "2025-12-06"; // Placeholder date for now
        self.conn.execute(
            "INSERT INTO memories (content, date_added) VALUES (?1, ?2)",
            params![content, date],
        )?;
        Ok(())
    }

    // 4. Read all memories (We will use this later)
    pub fn get_memories(&self) -> Result<Vec<String>> {
        let mut stmt = self.conn.prepare("SELECT content FROM memories ORDER BY id DESC")?;
        let rows = stmt.query_map([], |row| row.get(0))?;

        let mut results = Vec::new();
        for r in rows {
            results.push(r?);
        }
        Ok(results)
    }
=======
use std::ffi::CStr; // CString is no longer needed
use std::sync::Arc;
use parking_lot::Mutex; // Used for thread-safe mutable access
use rusqlite::Connection; // The core database driver
use std::ptr; // Used for ptr::null_mut() in error handling

// --- 1. The FFI Pointer Struct ---
// Opaque struct required for FFI boundary
#[repr(C)]
pub struct DbHandle;

// --- 2. The Thread-Safe Database Wrapper Struct ---
// Holds the Arc<Mutex<Connection>> for safe, shared access
pub struct VaultDb {
    pub conn: Arc<Mutex<Connection>>,
}

impl VaultDb {
    /// Creates a new VaultDb instance from an established rusqlite Connection.
    pub fn new(connection: Connection) -> Self {
        VaultDb {
            // Wrap the Connection in Arc and Mutex
            conn: Arc::new(Mutex::new(connection)),
        }
    }

    /// Helper function to safely get a reference to the Connection.
    pub fn get_connection(&self) -> parking_lot::MutexGuard<'_, Connection> {
        self.conn.lock()
    }
}


// --- FFI Function: Open Database ---

/// # Safety
/// This function is unsafe because it takes raw C pointers and returns a raw C pointer.
#[no_mangle]
pub unsafe extern "C" fn vault_db_open(
    db_path: *const i8,
    key_ptr: *const i8,
) -> *mut DbHandle {
    // 1. Check for null pointers and convert C strings to Rust strings
    if db_path.is_null() || key_ptr.is_null() {
        eprintln!("Error: Database path or key pointer is null.");
        return ptr::null_mut();
    }

    let path_cstr = CStr::from_ptr(db_path);
    let key_cstr = CStr::from_ptr(key_ptr);

    let path = match path_cstr.to_str() {
        Ok(s) => s,
        Err(_) => {
            eprintln!("Error: Invalid UTF-8 sequence in database path.");
            return ptr::null_mut();
        }
    };

    let key = match key_cstr.to_str() {
        Ok(s) => s,
        Err(_) => {
            eprintln!("Error: Invalid UTF-8 sequence in encryption key.");
            return ptr::null_mut();
        }
    };

    // 2. Open the rusqlite connection
    let conn = match Connection::open(path) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("Error opening database at {}: {:?}", path, e);
            return ptr::null_mut();
        }
    };

    // 3. Set the encryption key using PRAGMA
    if let Err(e) = conn.execute(&format!("PRAGMA key='{}'", key), []) {
        eprintln!("Error setting SQLCipher key: {:?}", e);
        return ptr::null_mut();
    }

    // 4. Wrap the connection and transfer ownership to the FFI caller
    let vault_db = VaultDb::new(conn);
    // Box::into_raw transfers ownership and returns the raw pointer
    Box::into_raw(Box::new(vault_db)) as *mut DbHandle
}


// --- FFI Function: Close Database ---

/// # Safety
/// This function is unsafe because it takes a raw C pointer.
#[no_mangle]
pub unsafe extern "C" fn vault_db_close(handle: *mut DbHandle) {
    if handle.is_null() {
        return;
    }
    // Reclaim ownership from the raw pointer.
    // When the Box goes out of scope, it automatically drops VaultDb,
    // which drops Arc/Mutex/Connection, safely closing the DB.
    let _ = Box::from_raw(handle as *mut VaultDb);
>>>>>>> 7cddacf (Description of the work I completed before pulling)
}