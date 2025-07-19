const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AuditAggregator - finalizeAudit()", function () {
  let AuditAggregator, auditAggregator;
  let signer, addr1;
  const dummyAuditId = ethers.utils.formatBytes32String("audit-001");
  const dummyDataHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("some audit content"));

  before(async function () {
    [signer, addr1] = await ethers.getSigners();
    AuditAggregator = await ethers.getContractFactory("AuditAggregator");
    auditAggregator = await AuditAggregator.deploy();
    await auditAggregator.deployed();
  });

  it("should finalize an audit with a valid ECDSA signature", async function () {
    // Sign hash with signer
    const signature = await signer.signMessage(ethers.utils.arrayify(dummyDataHash));

    // Call finalizeAudit with valid signature
    const tx = await auditAggregator.finalizeAudit(dummyAuditId, dummyDataHash, signature);
    await tx.wait();

    // Read result from contract
    const result = await auditAggregator.auditResults(dummyAuditId);

    expect(result.auditId).to.equal(dummyAuditId);
    expect(result.dataHash).to.equal(dummyDataHash);
    expect(result.finalized).to.equal(true);
    expect(result.signers[0]).to.equal(signer.address);

    console.log("Audit finalized successfully with signer:", result.signers[0]);
  });

  it("should reject invalid signature", async function () {
    const invalidSig = await addr1.signMessage(ethers.utils.arrayify(dummyDataHash));

    // Change data hash to mismatch
    const fakeHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("tampered data"));

    await expect(
      auditAggregator.finalizeAudit(dummyAuditId, fakeHash, invalidSig)
    ).to.be.revertedWith("Invalid signature");
  });

  it("should prevent double finalization", async function () {
    await expect(
      auditAggregator.finalizeAudit(dummyAuditId, dummyDataHash, "0x")
    ).to.be.revertedWith("Audit already finalized");
  });
});
