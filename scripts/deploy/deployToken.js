const { ethers } = require("hardhat");
const fs = require("fs");
require('dotenv').config();

async function main() {
    
 const Token = await ethers.getContractFactory("Vik");
 const token = await Token.deploy()
 await token.deployed();

 console.log("Token deployed to:", token.address);
 fs.writeFileSync(
    "./scripts/data/deployToken.json",
    JSON.stringify({ TokenAddress: token.address })
  );
}

main();