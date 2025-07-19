const { expect } = require("chai");

describe("IdentityRegistry", function () {
  let contract, v1, v2, v3, m1;

  beforeEach(async () => {
    [v1, v2, v3, m1] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("IdentityRegistry");
    contract = await Contract.deploy([v1.address, v2.address, v3.address], 2, 2);
    await contract.deployed();
  });

  it("should allow onboarded member to register and read DID and x509", async () => {
    await contract.connect(m1).requestOnboarding("dummy");
    await contract.connect(v1).approveMember(m1.address);
    await contract.connect(v2).approveMember(m1.address);
    await contract.connect(m1).registerIdentity("did:onboarded:abc", "x509:onboarded:cert");

    const did = await contract.connect(m1).readDID(m1.address);
    const x509 = await contract.connect(m1).readX509(m1.address);

    expect(did).to.equal("did:onboarded:abc");
    expect(x509).to.equal("x509:onboarded:cert");
  });

  it("should prevent non-onboarded member from reading identity data", async () => {
    await contract.connect(m1).requestOnboarding("dummy");
    await expect(contract.connect(m1).readDID(m1.address)).to.be.revertedWith("Access denied");
    await expect(contract.connect(m1).readX509(m1.address)).to.be.revertedWith("Access denied");
  });
});
