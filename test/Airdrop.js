const { expect } = require("chai");
const { Signer, Wallet } = require("ethers");
const { ethers } = require("hardhat");
const Web3 = require('web3');

describe("Airdrop",()=>{
    let owner;
    let address1;
    let address2;
    let signer
    let airdrop ;
    let airdropCon;
    let nft;
    let nftCon;
    let token;
    let tokenCon
    const provider = hre.ethers.provider;
    before(async()=>{
        [owner, address1, address2, signer] = await ethers.getSigners();
        nft = await ethers.getContractFactory("xVik");
        token = await ethers.getContractFactory("Vik");
        airdrop = await ethers.getContractFactory("Airdrop");

        nftCon = await nft.deploy("abc/","xVik","xVik");
        await nftCon.deployed();

        tokenCon = await token.deploy("Vik","Vik");
        await tokenCon.deployed();

        airdropCon = await airdrop.deploy();
        await airdropCon.deployed();
        await airdropCon.initialize(nftCon.address, tokenCon.address)

        // send token to Airdrop Contract
        await tokenCon.transfer(airdropCon.address, ethers.utils.parseEther("1000000"))
    })
    describe("Mint NFT",()=>{
      it("Mint NFT fail",async()=>{

      })
      it("Mint NFT succeed", async()=>{

      })
    })
    describe("Claim Airdrop",()=>{

    })
})