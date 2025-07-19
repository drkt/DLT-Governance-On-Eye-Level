// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract AuditLog {
    mapping(address => string[]) internal auditLog;

    event AuditEntry(address indexed target, string message);

    function logAudit(address _target, string memory _entry) internal {
        auditLog[_target].push(_entry);
        emit AuditEntry(_target, _entry);
    }

    function getAuditLog(address _member) public view returns (string[] memory) {
        return auditLog[_member];
    }
}
