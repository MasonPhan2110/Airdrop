const { ethers, upgrades } = require("hardhat");
const fs = require("fs");

async function main() {
 let file = fs.readFileSync(
    "./scripts/data/deployNFT.json",
    "utf8"
 );
 let data = JSON.parse(file);
    
 if (!data || !data.NFTAddress) throw new Error("Invalid JSON data");
    
 let NFTAddress = data.NFTAddress

 file = fs.readFileSync(
    "./scripts/data/deployToken.json",
    "utf8"
 );
 data = JSON.parse(file);
    
 if (!data || !data.TokenAddress) throw new Error("Invalid JSON data");
 let TokenAddress = data.TokenAddress

 const Airdrop = await ethers.getContractFactory("Airdrop");

 console.log("Deploying Proxy Airdrop...");

 const airdrop = await upgrades.deployProxy(Airdrop,[NFTAddress,TokenAddress], {
  initializer: "initialize",
});
 await airdrop.deployed();

 console.log("Airdrop Proxy deployed to:", airdrop.address);

 fs.writeFileSync(
    "./scripts/data/deployAirdropProxy.json",
    JSON.stringify({ AirdropProxy: airdrop.address })
  );
}

main();