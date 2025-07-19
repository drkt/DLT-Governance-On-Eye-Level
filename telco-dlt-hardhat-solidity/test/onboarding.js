const { expect } = require("chai");

describe("TelcoDLTGovernance", function () {
  let contract, owner, v1, v2, m1;

  beforeEach(async () => {
    [owner, v1, v2, m1] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("TelcoDLTGovernance");
    contract = await Contract.deploy([v1.address, v2.address], 2);
    await contract.deployed();
  });

  it("should onboard a member after multisig approval", async () => {
    await contract.connect(m1).requestOnboarding("did:telco:123");
    await contract.connect(v1).approveMember(m1.address);
    await contract.connect(v2).approveMember(m1.address);

    const status = await contract.getMemberStatus(m1.address);
    expect(status).to.equal(2); // Onboarded

    const logs = await contract.getAuditLog(m1.address);
    expect(logs).to.include("Member onboarded.");
  });

  it("should reject a member", async () => {
    await contract.connect(m1).requestOnboarding("did:telco:456");
    await contract.connect(owner).rejectMember(m1.address);

    const status = await contract.getMemberStatus(m1.address);
    expect(status).to.equal(3); // Rejected
  });

  it("should offboard a member", async () => {
    await contract.connect(m1).requestOnboarding("did:telco:789");
    await contract.connect(v1).approveMember(m1.address);
    await contract.connect(v2).approveMember(m1.address);

    await contract.connect(v1).offboardMember(m1.address);
    const status = await contract.getMemberStatus(m1.address);
    expect(status).to.equal(4); // Offboarded
  });
});
