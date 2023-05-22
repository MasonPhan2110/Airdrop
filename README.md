# CLAIM AIRDROP CONTRACT

A Project that allow claim airdrop.

## Demo website

- https://solana-swap-ashy.vercel.app/
- Token address on BSCTestnet :
- NFT address on BSCTestnet :
- Airdrop address on BSCTestnet :

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

### Environment

Create .env file with these variable

- RPC = ""
- PRIVATE_KEY = ""
- API = ""

## Testing

The testing scripts is located in the `test\` folders

Run `npx hardhat test` to test the project
