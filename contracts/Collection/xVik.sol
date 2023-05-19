// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../Interface/IAirdrop.sol";

contract xVik is ERC721, Ownable, ReentrancyGuard {
    using Strings for uint256;
    using Counters for Counters.Counter;
    // == VARIABLES == //

    IAirdrop public airdrop;

    
    // Optional base URI
    string public baseURI = "";

    mapping(uint256 => uint256) scarcitiesOfNFT;
    mapping(bytes => bool) signatureInvalid;
    

    Counters.Counter tokenId_;
    address _signer;

    // == STRUCTURES == //


    event Mint(address indexed to_,
        uint256[] tokenIds,
        uint256 totalCopies_,
        string internalId_
    );
    
    
    
    constructor(string memory baseURI_, string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        setURI(baseURI_);
        tokenId_._value = 0;
    }


    /**
     * @dev Set to new uri
     * @param uri_ new uri
     */
    function setURI(string memory uri_) public onlyOwner {
        baseURI = uri_;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }


    /**
     * @dev Handle Mint NFT
     * @param to_: address receive NFT
     * @param scarcity_ scarcity of NFT
    */
    function _handleMint(
        address to_,
        uint256 scarcity_
    ) internal returns(uint256) {
        tokenId_.increment();
        uint256 _tokenId = tokenId_.current();
        _safeMint(to_, _tokenId);
        scarcitiesOfNFT[_tokenId] = scarcity_;


        return _tokenId;
    }

    /**
     * @dev Handle Transfer NFT
     * @param from_ address send NFT
     * @param to_: address receive NFT
     * @param id_: tokenId of NFT
    */
    function _handleTransfer(address from_, address to_, uint256 id_, bytes memory data_) internal {
        _safeTransfer(from_, to_, id_, data_);
        airdrop.transferNFT(from_, to_, scarcitiesOfNFT[id_]);
    }



    /**
     * @dev Handle mint request
     * @param to_ the address to receive NFTs
     * @param internalId_ internal ID
     * @param amount_ the amount of token minted
     * @param scarcities_ scarcities of NFT (0: Super Rare, 1: Rare, 2: Normal)
     * @param signature: Signature
     */
    function mint(
        address to_,
        string memory internalId_,
        uint256 amount_,
        uint256[] memory scarcities_,
        bytes memory signature 
    )
        public
        returns (uint256[] memory, uint256 totalSupply, uint256 totalMinted)
    {  
        uint256 totalAmount = 0;

        uint256[] memory tokenIds = new uint256[](amount_);
        require(scarcities_.length == amount_,"xVik: Input data invalid");


        if(msg.sender != owner()){
            require(!signatureInvalid[signature] && verify(internalId_, to_,amount_,scarcities_, signature), "xVik: Signature is invalid");
            signatureInvalid[signature] = true;
        }

        for (uint256 i = 0; i < amount_; i++) {
            tokenIds[i] = _handleMint(to_, scarcities_[i]);
            if (scarcities_[i] == 0) {
                totalAmount += 5;
            } else if (scarcities_[i] == 1) {
                totalAmount += 2;
            } else {
                totalAmount += 1;
            }
        }
        airdrop.mintNFT(to_, totalAmount);


        emit Mint(to_,tokenIds, totalSupply, internalId_);

        return (tokenIds, totalSupply, totalMinted);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override nonReentrant {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "xVik: transfer caller is not owner nor approved");
        _handleTransfer(from, to, tokenId, data);
    }
    
    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override nonReentrant {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "xVik: transfer caller is not owner nor approved");

        _handleTransfer(from, to, tokenId, "");
    }

    function upgradeLevel(uint256 tokenId) external nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "xVik: only Owner of token can upgrade level");
    }


    /**
     * @dev Return Message Hash
     * @param _internalId internal ID
     * @param _to: address of user claim NFT
     * @param _amount: amount of NFT
     * @param scarcities_ scarcities of NFT (0: Super Rare, 1: Rare, 2: Normal)
     * @param _amount: amount of token
    */
    function getMessageHash(
        string memory _internalId,
        address _to,
        uint256 _amount,
        uint256[] memory scarcities_
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_internalId,_to,_amount, scarcities_));
    }

    /**
     * @dev Return ETH Signed Message Hash
     * @param _messageHash: Message Hash
    */
    function getEthSignedMessageHash(bytes32 _messageHash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    /**
     * @dev Return True/False
     * @param _internalId internal ID
     * @param _to: address of user claim NFT
     * @param _amount: amount of NFT
     * @param scarcities_ scarcities of NFT (0: Super Rare, 1: Rare, 2: Normal)
     * @param signature: sign the message hash offchain
    */
    function verify(
        string memory _internalId,
        address _to,
        uint256 _amount,
        uint256[] memory scarcities_,
        bytes memory signature
    ) internal view returns (bool) {
        bytes32 messageHash = getMessageHash(_internalId,_to, _amount, scarcities_);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    /**
     * @dev Return address of signer
     * @param _ethSignedMessageHash: ETH Signed Message Hash
     * @param _signature: sign the message hash offchain
    */
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        internal
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    /**
     * @dev Return split Signature
     * @param sig: sign the message hash offchain
    */
    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }


    function setSigner(address newSigner) external onlyOwner{
        _signer = newSigner;
    }
}
