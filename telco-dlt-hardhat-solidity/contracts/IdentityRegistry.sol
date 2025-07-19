// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TelcoGovernance.sol";

contract IdentityRegistry is TelcoGovernance {
    struct IdentityData {
        string did;
        string x509;
    }

    mapping(address => IdentityData) private identityStore;

    function registerIdentity(string memory _did, string memory _x509) public {
        require(members[msg.sender].status == MemberStatus.Onboarded, "Only onboarded members can register");
        identityStore[msg.sender] = IdentityData(_did, _x509);
        logAudit(msg.sender, "DID and x509 registered.");
    }

    function readDID(address member) public view returns (string memory) {
        require(members[msg.sender].status == MemberStatus.Onboarded, "Access denied");
        return identityStore[member].did;
    }

    function readX509(address member) public view returns (string memory) {
        require(members[msg.sender].status == MemberStatus.Onboarded, "Access denied");
        return identityStore[member].x509;
    }
}
