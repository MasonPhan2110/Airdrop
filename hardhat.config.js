require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
require("@nomiclabs/hardhat-etherscan");
require("@openzeppelin/hardhat-upgrades");

module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
      allowUnlimitedContractSize: true
    },
    bscTestnet: {
      url: process.env.RPC,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 97
      // gas: 2100000,
      // gasPrice: 8000000000
    },
    bscMainnet:{
      url : process.env.RPC,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 56
    },
    ethTestnet:{
      url : process.env.RPC,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 5
    },
    ethMainnet:{
      url : process.env.RPC,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 1
    },
    polygonTestnet:{
      url : process.env.RPC,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 80001
    },
    polygonMainnet:{
      url : process.env.RPC,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 137
    }
  },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      }
    }
  },
  etherscan: {
    apiKey: process.env.API
  },
  paths:{
    tests: "./test",
  }
};
