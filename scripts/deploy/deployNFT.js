const { ethers } = require("hardhat");
const fs = require("fs");
require('dotenv').config();

async function main() {
 let baseURI = "abc/"
 let name = "xVik"
 let symbol = "xVik"
 const NFT = await ethers.getContractFactory("xVik");
 const nft = await NFT.deploy(baseURI, name, symbol)
 await nft.deployed();

 console.log("NFT deployed to:", nft.address);
 fs.writeFileSync(
    "./scripts/data/deployNFT.json",
    JSON.stringify({ NFTAddress: nft.address })
  );
}

main();