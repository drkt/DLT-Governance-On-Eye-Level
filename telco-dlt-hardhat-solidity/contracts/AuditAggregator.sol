// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuditAggregator {
    struct AuditResult {
        bytes32 auditId;
        bytes32 dataHash;
        address[] signers;
        bytes signature;
        bool finalized;
    }

    mapping(bytes32 => AuditResult) public auditResults;

    event AuditFinalized(bytes32 indexed auditId, address signer, bytes32 dataHash);

    function finalizeAudit(
        bytes32 auditId,
        bytes32 dataHash,
        bytes memory signature
    ) public {
        require(!auditResults[auditId].finalized, "Audit already finalized");

        address signer = recoverSigner(dataHash, signature);
        require(signer != address(0), "Invalid signature");

        auditResults[auditId] = AuditResult({
            auditId: auditId,
            dataHash: dataHash,
            signers: new address[](1),
            signature: signature,
            finalized: true
        });
        auditResults[auditId].signers[0] = signer;

        emit AuditFinalized(auditId, signer, dataHash);
    }

    function recoverSigner(bytes32 hash, bytes memory sig) internal pure returns (address) {
        if (sig.length != 65) return address(0);
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }
        if (v < 27) v += 27;
        if (v != 27 && v != 28) return address(0);
        return ecrecover(hash, v, r, s);
    }
}
