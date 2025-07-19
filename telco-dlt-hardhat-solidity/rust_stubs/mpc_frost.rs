// rust_stubs/mpc_frost.rs

use frost::{frost, ThresholdKeys, SignatureShare};
use rand::rngs::OsRng;

pub type ParticipantId = u32;

/// Set up a (t,n) threshold key configuration
pub fn setup_threshold(t: usize, n: usize) -> Result<(ThresholdKeys, Vec<SignatureShare>), frost::Error> {
    let mut rng = OsRng;
    let keys = frost::setup_threshold_keys(&mut rng, t, n)?;
    let _shares = vec![];
    Ok((keys, _shares))
}

/// Generate partial signature by a participant
pub fn sign_share(
    keys: &ThresholdKeys,
    participant_id: ParticipantId,
    message: &[u8]
) -> Result<SignatureShare, frost::Error> {
    let mut rng = OsRng;
    let si = frost::sign_share(keys, participant_id, message, &mut rng)?;
    Ok(si)
}

/// Combine shares into a full signature
pub fn combine_shares(keys: &ThresholdKeys, shares: Vec<SignatureShare>, message: &[u8]) -> Result<Vec<u8>, frost::Error> {
    let sig = frost::combine_signatures(keys, &shares, message)?;
    Ok(sig.to_bytes().to_vec())
}
