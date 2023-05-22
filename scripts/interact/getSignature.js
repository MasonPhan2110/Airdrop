const Web3 = require('web3');

async function main(){
    contractAddress = ""
    const hashMessage = await Web3.utils.soliditySha3(
        "internalid",
        "0x105112af5cDAA0AB3B7A3dB6ca495E0A4F72D154", // Receiver
        0 // Scarity 0 is Super Rare, 1 is Rare, 2 is Normal
      );
      console.log(hashMessage);
      const privateKey = "5a1d47ed36bae797c576a4fa350721130344781e676bfca5d82f0aa6917e354b"
      const web3 = new Web3("https://data-seed-prebsc-1-s2.binance.org:8545");
        web3.eth.accounts.privateKeyToAccount(privateKey);
      const signature = web3.eth.accounts.sign(hashMessage, privateKey);
      console.log(signature);
}
main()
