const { expect } = require("chai");

describe("TelcoDLTGovernance", function () {
  let contract, v1, v2, v3, m1;

  beforeEach(async () => {
    [v1, v2, v3, m1] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("TelcoDLTGovernance");
    contract = await Contract.deploy([v1.address, v2.address, v3.address], 2, 2);
    await contract.deployed();
  });

  it("should onboard after multisig approval", async () => {
    await contract.connect(m1).requestOnboarding("did:abc:123");
    await contract.connect(v1).approveMember(m1.address);
    await contract.connect(v2).approveMember(m1.address);
    const status = await contract.getMemberStatus(m1.address);
    expect(status).to.equal(2); // Onboarded
  });

  it("should reject after multisig rejection", async () => {
    await contract.connect(m1).requestOnboarding("did:xyz:456");
    await contract.connect(v1).rejectMember(m1.address);
    await contract.connect(v2).rejectMember(m1.address);
    const status = await contract.getMemberStatus(m1.address);
    expect(status).to.equal(3); // Rejected
  });

  it("should offboard an onboarded member", async () => {
    await contract.connect(m1).requestOnboarding("did:foo:789");
    await contract.connect(v1).approveMember(m1.address);
    await contract.connect(v2).approveMember(m1.address);
    await contract.connect(v1).offboardMember(m1.address);
    const status = await contract.getMemberStatus(m1.address);
    expect(status).to.equal(4); // Offboarded
  });
});
