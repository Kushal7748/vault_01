// rust/src/api/simple.rs

// --- 1. SIMPLE BRIDGE TEST ---

// This function receives the memory text from Flutter
pub fn save_memory(content: String) -> String {
    // 1. Validation: Check if the memory is empty
    if content.is_empty() {
        return "Error: Memory cannot be empty".to_string();
    }

    // 2. Debugging: Print to the Rust console so we can see it working
    println!("RUST: Received memory -> {}", content);

    // 3. Response: Return a success message back to Flutter
    // (We will swap this with the Database code you showed me tomorrow!)
    format!("Successfully secured {} characters!", content.len())
}