// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

interface IAirdrop {
    function transferNFT(address from, address to, uint256 amount) external;
    function mintNFT(address to, uint256 amount) external;
}