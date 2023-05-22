# CLAIM AIRDROP CONTRACT

A Project that allow claim airdrop.

## Demo website

-
- Token address on BSCTestnet : 0xcbF26e3835A95748AB360BbdE8F4Fe4c1Be115c5
- NFT address on BSCTestnet : 0x2c6CFe642d982f21B1146a8F0613CA8374fF63B8
- Airdrop address on BSCTestnet : 0x297f7F2C68Bf197b748AC65E3C89d05849D2fc8f

## Project structure

The program using the following mechanism to handle the claim airdrop:

1. An `owner` of Airdrop Contract transfer 1,000,000 tokens to Airdrop Contract at 00:00 GMT.

2. When a user claim airdrop, they receives Vik token, the number of tokens that will be in the tier of NFT (Super Rare: x5, Rare: x2, Normal: x1). The operation is perform via the `claimAirdrop` functions. -- Airdrop.sol

3. When a user wants to upgrade the tier of NFT, he sends Vik token to Airdrop Contract, and the tier of NFT will be increased according to the following rule: Normal -> Rare is 10 Vik and Rare is Super Rare: 50 Vik. The operation is perform via the `upgradeTier` functions. -- Airdrop.sol

## Deployment

Deploy contract on bscTestnet:

- To deploy Airdrop Contract Proxy: npm run deploy::ProxyAirdrop bscTestnet
- To deploy NFT Contract: npm run deploy::NFT bscTestnet
- To deploy Token Contract: npm run deploy::Token bscTestnet

## Verify

Verify contract on BscScan:

- To verify Airdrop Contract Proxy: npm run verify::Airdrop bscTestnet
- To verify NFT Contract: npm run verify::NFT bscTestnet
- To verify Token Contract: npm run verify::Token bscTestnet

## Interactive scripts

To generate Signature for mint NFT, run `node scripts/interact/getSignature.js` (change the data inside `getSignature` to get the right signature)

### Environment

Create .env file with these variable

- RPC = ""
- PRIVATE_KEY = ""
- API = ""

## Testing

The testing scripts is located in the `test\` folders

Run `npx hardhat test` to test the project
