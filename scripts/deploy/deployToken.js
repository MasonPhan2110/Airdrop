const { ethers } = require("hardhat");
const fs = require("fs");
require('dotenv').config();

async function main() {
 let name = "Vik"
 let symbol = "Vik"
 const Token = await ethers.getContractFactory("Vik");
 const token = await Token.deploy(name, symbol)
 await token.deployed();

 console.log("Token deployed to:", token.address);
 fs.writeFileSync(
    "./scripts/data/deployToken.json",
    JSON.stringify({ TokenAddress: token.address })
  );
}

main();