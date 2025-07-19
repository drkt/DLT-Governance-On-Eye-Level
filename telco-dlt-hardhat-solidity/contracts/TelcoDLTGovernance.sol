// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TelcoDLTGovernance {
    enum MemberStatus { None, Pending, Onboarded, Rejected, Offboarded }

    struct Member {
        address addr;
        string didOrCert;
        MemberStatus status;
    }

    address public owner;
    address[] public validators;
    mapping(address => Member) public members;
    mapping(address => mapping(address => bool)) public approvals;
    mapping(address => uint8) public approvalCount;
    uint8 public requiredApprovals;

    mapping(address => string[]) public auditLog;

    event MemberRequested(address member, string did);
    event MemberApproved(address validator, address member);
    event MemberOnboarded(address member);
    event MemberRejected(address member);
    event MemberOffboarded(address member);
    event AuditEntry(address target, string entry);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyValidator() {
        bool isValidator = false;
        for (uint i = 0; i < validators.length; i++) {
            if (validators[i] == msg.sender) {
                isValidator = true;
                break;
            }
        }
        require(isValidator, "Not validator");
        _;
    }

    constructor(address[] memory _validators, uint8 _requiredApprovals) {
        owner = msg.sender;
        validators = _validators;
        requiredApprovals = _requiredApprovals;
    }

    function requestOnboarding(string memory _didOrCert) public {
        require(members[msg.sender].status == MemberStatus.None, "Already requested");
        members[msg.sender] = Member(msg.sender, _didOrCert, MemberStatus.Pending);
        emit MemberRequested(msg.sender, _didOrCert);
        logAudit(msg.sender, "Onboarding requested.");
    }

    function approveMember(address _member) public onlyValidator {
        require(members[_member].status == MemberStatus.Pending, "Not pending");
        require(!approvals[msg.sender][_member], "Already approved");

        approvals[msg.sender][_member] = true;
        approvalCount[_member]++;

        emit MemberApproved(msg.sender, _member);
        logAudit(_member, "Validator approved.");

        if (approvalCount[_member] >= requiredApprovals) {
            members[_member].status = MemberStatus.Onboarded;
            emit MemberOnboarded(_member);
            logAudit(_member, "Member onboarded.");
        }
    }

    function rejectMember(address _member) public onlyOwner {
        require(members[_member].status == MemberStatus.Pending, "Not pending");
        members[_member].status = MemberStatus.Rejected;
        emit MemberRejected(_member);
        logAudit(_member, "Member rejected by owner.");
    }

    function offboardMember(address _member) public onlyValidator {
        require(members[_member].status == MemberStatus.Onboarded, "Not onboarded");
        members[_member].status = MemberStatus.Offboarded;
        emit MemberOffboarded(_member);
        logAudit(_member, "Member offboarded by validator.");
    }

    function logAudit(address _target, string memory _entry) internal {
        auditLog[_target].push(_entry);
        emit AuditEntry(_target, _entry);
    }

    function getAuditLog(address _member) public view returns (string[] memory) {
        return auditLog[_member];
    }

    function getMemberStatus(address _member) public view returns (MemberStatus) {
        return members[_member].status;
    }
}
