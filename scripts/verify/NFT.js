const console = require("console")
const hre= require("hardhat")
const fs = require("fs");

// Define the NFT

async function main() {
    const contract_sol_url = "contracts/Collections/xVik.sol:xVik";
    const file = fs.readFileSync(
      "./scripts/data/deployNFT.json",
      "utf8"
    );
    const data = JSON.parse(file);
    if (!data || !data.NFTAddress) throw new Error("Invalid JSON data");
    let baseURI = "abc/"
    let name = "xVik"
    let symbol = "xVik"
    await hre.run('verify:verify', {
        address: data.NFTAddress,
        constructorArguments: [
            baseURI,
            name, 
            symbol
        ],
        contract: contract_sol_url
    })
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })