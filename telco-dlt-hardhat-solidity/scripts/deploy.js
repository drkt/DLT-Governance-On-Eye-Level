const hre = require("hardhat");

async function main() {
  const [v1, v2, v3] = await hre.ethers.getSigners();
  const Contract = await hre.ethers.getContractFactory("IdentityRegistry");
  const contract = await Contract.deploy([v1.address, v2.address, v3.address], 2, 2);
  await contract.deployed();
  console.log("IdentityRegistry deployed at:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
