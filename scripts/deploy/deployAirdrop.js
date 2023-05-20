const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const Airdrop = await hre.ethers.getContractFactory("Airdrop");
  const airdrop = await Airdrop.deploy();
  await airdrop.deployed();

  console.log("airdrop deployed to:", airdrop.address);

  fs.writeFileSync(
    "./scripts/data/deployAirdropProxy.json",
    JSON.stringify({ AirdropProxy: airdrop.address })
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
