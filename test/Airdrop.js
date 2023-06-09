const { expect } = require("chai");
const { Signer, Wallet } = require("ethers");
const { ethers } = require("hardhat");
const Web3 = require('web3');

describe("Airdrop",()=>{
    let owner;
    let address1;
    let address2;
    let address3;
    let signer
    let airdrop ;
    let airdropCon;
    let nft;
    let nftCon;
    let token;
    let tokenCon;
    let singerPrivatekey;
    const provider = hre.ethers.provider;
    before(async()=>{
        [owner, address1, address2, address3, signer] = await ethers.getSigners();
        singerPrivatekey = "0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a"
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
        await tokenCon.transfer(airdropCon.address, ethers.utils.parseEther("10000000"))
        // set signer to NFT Contract
        await nftCon.setSigner(signer.address)
        // set contract airdrop in NFT
        await nftCon.setAirdrop(airdropCon.address)
    })
    describe("Mint NFT",()=>{
      it("Mint NFT fail",async()=>{
        const hashMessage = await Web3.utils.soliditySha3(
          "abcde",
          address1.address,
          0
        );
        const web3 = new Web3("http://127.0.0.1:8545/");
        const signature = web3.eth.accounts.sign(hashMessage,singerPrivatekey).signature;
        
        // Mint NFT type Rare to address 1
        await expect(nftCon.connect(address1).mint("abcdef", 0,signature)).to.be.reverted
        
      })
      it("Mint NFT succeed for address 1", async()=>{
        const hashMessage = await Web3.utils.soliditySha3(
          "abcdef",
          address1.address,
          0
        );
        const web3 = new Web3("http://127.0.0.1:8545/");
        const signature = web3.eth.accounts.sign(hashMessage,singerPrivatekey).signature;
        
        // Mint NFT type Super Rare to address 1
        expect(await nftCon.connect(address1).mint("abcdef", 0,signature)).to.be.ok

        // Check owner data in Airdrop contract
        let ownerData = await airdropCon.connect(address1).getOwnerData(1);
        expect(ownerData.balance).to.be.equal(5)
        // Check Pool Info
        let poolInfo = await airdropCon.poolInfos(1);
        expect(poolInfo.totalDeposit).to.be.equal(5)
        
      })
      it("Mint NFT succeed for address 2", async()=>{
        const hashMessage = await Web3.utils.soliditySha3(
          "abcdef",
          address2.address,
          1
        );
        const web3 = new Web3("http://127.0.0.1:8545/");
        const signature = web3.eth.accounts.sign(hashMessage, singerPrivatekey).signature;
        
        // Mint NFT type Rare to address 2
        expect(await nftCon.connect(address2).mint("abcdef", 1,signature)).to.be.ok

        // Check owner data in Airdrop contract
        let ownerData = await airdropCon.connect(address2).getOwnerData(2);
        expect(ownerData.balance).to.be.equal(2)
        // Check Pool Info
        let poolInfo = await airdropCon.poolInfos(1);
        expect(poolInfo.totalDeposit).to.be.equal(7)
      })
      it("Mint NFT succeed for address 3", async()=>{
        const hashMessage = await Web3.utils.soliditySha3(
          "abcdef",
          address3.address,
          2
        );
        const web3 = new Web3("http://127.0.0.1:8545/");
        const signature = web3.eth.accounts.sign(hashMessage, singerPrivatekey).signature;
        
        // Mint NFT type Rare to address 1
        expect(await nftCon.connect(address3).mint("abcdef", 2,signature)).to.be.ok

        // Check owner data in Airdrop contract
        let ownerData = await airdropCon.connect(address3).getOwnerData(3);
        expect(ownerData.balance).to.be.equal(1)
        // Check Pool Info
        let poolInfo = await airdropCon.poolInfos(1);
        expect(poolInfo.totalDeposit).to.be.equal(8)
      })
    })
    describe("Claim Airdrop",()=>{
      it("Address 1 claim airdrop in day 1", async() => {
        
        // expect(await airdropCon.connect(address1).pendingReward(1)).to.equal(ethers.utils.parseEther("625000"))
        expect(await airdropCon.connect(address1).claimAirdrop(1)).to.be.ok;
        expect(await tokenCon.balanceOf(address1.address)).to.equal(ethers.utils.parseEther("625000"));

      })
      it("Address 1 claim airdrop in day 1 return fail", async() =>{
        await expect(airdropCon.connect(address1).claimAirdrop(1)).to.be.reverted;
      })
      it("Address 1 transfer NFT to address 2 claim airdrop in day 1 return fail", async() =>{
        await nftCon.connect(address1).transferFrom(address1.address,address2.address, 1);
        
        await expect(airdropCon.connect(address2).claimAirdrop(1)).to.be.reverted;
      })
      it("Address 2 claim airdrop in day 1", async() => {
        // expect(await airdropCon.connect(address2).pendingReward(2)).to.equal(ethers.utils.parseEther("250000"))
        expect(await airdropCon.connect(address2).claimAirdrop(2)).to.be.ok;
        expect(await tokenCon.balanceOf(address2.address)).to.equal(ethers.utils.parseEther("250000"));
      })

      it("Address 2 claim airdrop in day 2", async() =>{
        
        // Set time to next day
        let blocktime = await airdropCon.blockTime();
        let time = blocktime.toNumber() + 86400;
        console.log(time);
        await ethers.provider.send('evm_setNextBlockTimestamp', [time]); 
        await ethers.provider.send('evm_mine');

        
        expect(await airdropCon.connect(address2).claimAirdrop(1)).to.be.ok;
        
        let poolId = await airdropCon.getPoolIdCurrent();
        console.log("PoolID: ",poolId);
        expect(await airdropCon.connect(address2).claimAirdrop(2)).to.be.ok;
        expect(await tokenCon.balanceOf(address2.address)).to.equal(ethers.utils.parseEther("1125000"));
      })
      it("Address 3 claim airdrop in day 3", async() =>{
        // Set time to next day
        let blocktime = await airdropCon.blockTime();
        let time = blocktime.toNumber() + 86400;
        console.log(time);
        await ethers.provider.send('evm_setNextBlockTimestamp', [time]); 
        await ethers.provider.send('evm_mine');

        expect(await airdropCon.connect(address3).claimAirdrop(3)).to.be.ok;
        expect(await tokenCon.balanceOf(address3.address)).to.equal(ethers.utils.parseEther("375000"));
      })
      it("Address 2 upgrade tier of NFT and claim airdrop in day 4", async()=>{
        // Set time to next day
        let blocktime = await airdropCon.blockTime();
        let time = blocktime.toNumber() + 86400;
        console.log(time);
        await ethers.provider.send('evm_setNextBlockTimestamp', [time]); 
        await ethers.provider.send('evm_mine');
        // upgrade tier 
        // upgrade tier fail because NFT already in Super rare tier
        await expect(airdropCon.connect(address2).upgradeTier(1,0)).to.be.reverted;
        // upgrade tier succeed
        await tokenCon.connect(address2).approve(airdropCon.address, ethers.utils.parseEther("50"))
        expect(await airdropCon.connect(address2).upgradeTier(2,0)).to.be.ok;
        console.log(await tokenCon.balanceOf(address2.address))
        // claim airdrop
        expect(await airdropCon.connect(address2).claimAirdrop(2)).to.be.ok;
        expect(await tokenCon.balanceOf(address2.address)).to.equal(ethers.utils.parseEther("1624950"));
      })
    })
})