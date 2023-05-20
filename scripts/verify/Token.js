const console = require("console")
const hre= require("hardhat")
const fs = require("fs");

// Define the NFT

async function main() {
    const contract_sol_url = "contracts/Collections/Vik.sol:Vik";
    const file = fs.readFileSync(
      "./scripts/data/deployToken.json",
      "utf8"
    );
    const data = JSON.parse(file);
    if (!data || !data.TokenAddress) throw new Error("Invalid JSON data");
    let name = "Vik"
    let symbol = "Vik"
    await hre.run('verify:verify', {
        address: data.TokenAddress,
        constructorArguments: [
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