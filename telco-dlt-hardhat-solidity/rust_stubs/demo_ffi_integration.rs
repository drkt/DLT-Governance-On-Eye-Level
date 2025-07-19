// demo_ffi_integration.rs

mod mpc_frost;
mod ffi_bridge;

use ffi_bridge::call_frost_sign;

fn main() {
    let audit_data = b"some audit content";
    let audit_hash = blake3::hash(audit_data).as_bytes().to_vec();

    println!("Audit hash: 0x{}", hex::encode(&audit_hash));

    // Simulate participant ID 1, threshold 2 of 3
    let id = 1u32;
    let threshold = 2usize;
    let total = 3usize;

    match call_frost_sign(&audit_hash, id, threshold, total) {
        Ok(signature) => {
            println!("Generated signature (hex): 0x{}", hex::encode(signature));
        }
        Err(err) => {
            println!("Error generating signature: {}", err);
        }
    }
}
