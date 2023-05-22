const {ethers} = require("hardhat");
const fs = require("fs");

async function main() {

    const contract_sol_url = "contracts/Token/Vik.sol:Vik";
    const file = fs.readFileSync(
      "./scripts/data/deployToken.json",
      "utf8"
    );
    const data = JSON.parse(file);
    if (!data || !data.TokenAddress) throw new Error("Invalid JSON data");
  const token = await ethers.getContractAt('Vik', data.TokenAddress);

  const amount =   ethers.utils.parseEther("10"); // change this
  const tx = await token.approve("0x297f7F2C68Bf197b748AC65E3C89d05849D2fc8f",amount)
  await tx.wait()

  console.log(`Approve has been done with txid ${tx}`);  
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
