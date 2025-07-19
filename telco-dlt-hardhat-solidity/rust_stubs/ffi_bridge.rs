// rust_stubs/ffi_bridge.rs

use super::mpc_frost::*;
use std::ffi::CStr;
use std::os::raw::{c_char, c_uchar, c_uint};
use std::slice;

#[no_mangle]
pub extern "C" fn perform_audit_frost(
    audit_ptr: *const c_uchar,
    audit_len: usize,
    id: c_uint,
    threshold: c_uint,
    total: c_uint,
    result_ptr: *mut c_uchar,
    result_len: usize
) -> i32 {
    let audit = unsafe { slice::from_raw_parts(audit_ptr, audit_len) };
    let id = id as u32;
    let t = threshold as usize;
    let n = total as usize;

    match call_frost_sign(audit, id, t, n) {
        Ok(sig) => {
            let len = sig.len().min(result_len);
            unsafe {
                std::ptr::copy_nonoverlapping(sig.as_ptr(), result_ptr, len);
            }
            0
        }
        Err(_) => -1
    }
}

/// Wrapper for signature generation via frost
pub fn call_frost_sign(
    message: &[u8],
    id: u32,
    t: usize,
    n: usize
) -> Result<Vec<u8>, String> {
    let (keys, mut shares) = setup_threshold(t, n).map_err(|e| e.to_string())?;
    let share = sign_share(&keys, id, message).map_err(|e| e.to_string())?;
    shares.push(share);
    if shares.len() >= t {
        let sig = combine_shares(&keys, shares, message).map_err(|e| e.to_string())?;
        Ok(sig)
    } else {
        Err("Not enough shares collected".into())
    }
}
