const { ethers } = require("hardhat");
const fs = require("fs");
require('dotenv').config();

async function main() {
    
 const NFT = await ethers.getContractFactory("xVik");
 const nft = await NFT.deploy()
 await nft.deployed();

 console.log("NFT deployed to:", nft.address);
 fs.writeFileSync(
    "./scripts/data/deployNFT.json",
    JSON.stringify({ NFTAddress: nft.address })
  );
}

main();