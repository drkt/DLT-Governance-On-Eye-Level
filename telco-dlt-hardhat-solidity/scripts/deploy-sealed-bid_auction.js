
const hre = require("hardhat");

async function main() {
    const SealedBidAuction = await hre.ethers.getContractFactory("SealedBidAuction");
    const auction = await SealedBidAuction.deploy(300, 300); // 5 min bidding, 5 min reveal
    await auction.deployed();
    console.log("Auction deployed to:", auction.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
