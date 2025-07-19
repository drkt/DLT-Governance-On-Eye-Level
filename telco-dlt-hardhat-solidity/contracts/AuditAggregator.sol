// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AuditAggregator {
    struct AuditVote {
        address auditor;
        bytes32 hash;
    }

    struct AuditSession {
        uint voteCount;
        mapping(address => bool) voted;
        AuditVote[] votes;
    }

    mapping(bytes32 => AuditSession) public audits;
    address[] public auditors;
    uint public quorum;

    event AuditRequested(bytes32 indexed auditId);
    event VoteSubmitted(bytes32 indexed auditId, address auditor);
    event AuditFinalized(bytes32 indexed auditId, bytes32 result);

    modifier onlyAuditor() {
        bool valid = false;
        for (uint i = 0; i < auditors.length; i++) {
            if (auditors[i] == msg.sender) {
                valid = true;
                break;
            }
        }
        require(valid, "Not authorized auditor");
        _;
    }

    constructor(address[] memory _auditors, uint _quorum) {
        auditors = _auditors;
        quorum = _quorum;
    }

    function requestAudit(bytes32 auditId) public {
        require(audits[auditId].voteCount == 0, "Already exists");
        emit AuditRequested(auditId);
    }

    function submitVote(bytes32 auditId, bytes32 hash) public onlyAuditor {
        AuditSession storage session = audits[auditId];
        require(!session.voted[msg.sender], "Already voted");
        session.voted[msg.sender] = true;
        session.votes.push(AuditVote(msg.sender, hash));
        session.voteCount++;
        emit VoteSubmitted(auditId, msg.sender);

        if (session.voteCount >= quorum) {
            emit AuditFinalized(auditId, hash); // simplistic: last hash as "final"
        }
    }

    function getAuditors() public view returns (address[] memory) {
        return auditors;
    }

    function getVoteCount(bytes32 auditId) public view returns (uint) {
        return audits[auditId].voteCount;
    }
}
