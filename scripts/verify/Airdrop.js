const console = require("console")
const hre= require("hardhat")
const fs = require("fs");
require("dotenv").config();

// Define the NFT

async function main() {
    const contract_sol_url = "contracts/Airdrop.sol:Airdrop";

    const file = fs.readFileSync(
      "./scripts/data/deployAirdropProxy.json",
      "utf8"
    );
    const data = JSON.parse(file);
  
    if (!data || !data.AirdropProxy) throw new Error("Invalid JSON data");

    await hre.run('verify:verify', {
        address: data.AirdropProxy,
        constructorArguments: [
            
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