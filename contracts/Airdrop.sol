// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract Airdrop is OwnableUpgradeable, UUPSUpgradeable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    /*================================ VARIABLES ================================*/
    Counters.Counter public poolId;
    uint256 constant DAY_IN_SECONDS = 86400;
    uint256 public rewardPerDay;
    address internal _nftContract;
    mapping (address => mapping(uint256 => OwnerData)) private ownerData;
    mapping (uint256 => PoolInfo) public poolInfos;
    mapping (uint256 => mapping(uint256 => ClaimInfo)) public claimInfo;
    uint256 public holder;
    uint256 public startDay;
    address public tokenAddress;

    /*================================ STRUCTS ================================*/
    struct OwnerData {
        uint256 startTime;
        uint256 balance;
        uint256 rewardClaimed;
        uint256 lastClaimed;
        uint256 lastUpdate;
        uint256 rewardPaid;
    }

    struct PoolInfo {
        uint256 createTime;
        uint256 totalDeposit;
        uint256 totalDepositForNextPool;
        uint256 lastRewardTime;
        uint256 rewardRemain;
        uint256 rewardPerNFT;
    }

    struct ClaimInfo {
        uint256 claimTime;
        uint256 reward;
        address user;
    }

    /*================================ EVENTS ================================*/
    event ClaimReward (
        address indexed user,
        uint256 balance,
        uint256 amount
    );

    /*=============================== FUNCTIONS ===============================*/
    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address) internal override onlyOwner {}

    function initialize(address NFTContract, address token_) public initializer {
        _nftContract = NFTContract;
        startDay = block.timestamp;
        rewardPerDay = 1_000_000 * 10**18;
        tokenAddress = token_;
        poolId._value = 1;
        ///@dev as there is no constructor, we need to initialise the OwnableUpgradeable explicitly
        __Ownable_init();

        
    }

    function transferNFT(address from, address to, uint256 tokenId, uint256 amount) external {
        require(msg.sender == _nftContract,"Only NFT contract can call");
        OwnerData storage dataFrom = ownerData[from][tokenId];
        OwnerData storage dataTo = ownerData[to][tokenId];

        updatePool(poolId.current());
        dataFrom.rewardPaid = earn(from,tokenId);
        dataTo.rewardPaid = earn(to,tokenId);

        dataTo.balance += amount;
        dataFrom.balance -= amount;
        dataFrom.lastUpdate = block.timestamp;
        if(claimInfo[poolId.current()][tokenId].claimTime > 0) {
            dataTo.lastUpdate = (block.timestamp).div(DAY_IN_SECONDS).add(1).mul(DAY_IN_SECONDS);
        } else {
            dataTo.lastUpdate = block.timestamp;
        }
        
        
    }
    function mintNFT(address to,uint256 tokenId, uint256 amount) external {
        require(msg.sender == _nftContract,"Only NFT contract can call");
        OwnerData storage data = ownerData[to][tokenId];

        updatePool(poolId.current());
        data.rewardPaid = earn(to, tokenId);

        data.balance += amount;
        data.lastUpdate = block.timestamp;
        PoolInfo storage pool = poolInfos[poolId.current()];
        pool.totalDeposit += amount;
        pool.totalDepositForNextPool += amount;
        pool.rewardPerNFT = rewardPerDay.div(pool.totalDeposit);

    }
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
       uint256 multiplier = (_to.div(DAY_IN_SECONDS)).sub(_from.div(DAY_IN_SECONDS));
       return multiplier;
    }
    function earn(address user, uint256 tokenId) internal view returns(uint256) {
        OwnerData memory data = ownerData[user][tokenId];
        uint256 multiplier;
        if (data.lastUpdate > block.timestamp) {
            return data.rewardPaid;
        }
        if (data.lastUpdate > 0) {
            multiplier = getMultiplier(data.lastUpdate, block.timestamp);
        }
        
        uint256 reward = 0;
        if (multiplier > 0) {
            for(uint256 i = poolId.current();i>poolId.current()-multiplier-1;i--){
                if (claimInfo[i][tokenId].claimTime == 0) {
                    reward += poolInfos[i].rewardPerNFT * data.balance;
                }
            }
        } else {
            reward = poolInfos[poolId.current()].rewardPerNFT * data.balance;
        }
        reward += data.rewardPaid;
        return reward;

    }
    function claimAirdrop(uint256 tokenId) external {
        OwnerData storage data = ownerData[msg.sender][tokenId];
        PoolInfo storage pool = poolInfos[poolId.current()];
        uint256 time = block.timestamp/DAY_IN_SECONDS - data.lastClaimed/DAY_IN_SECONDS;
        require(time >=1, "You already Claimed");

        updatePool(poolId.current());
        require(claimInfo[poolId.current()][tokenId].claimTime == 0,"This token already claimed airdrop");
        uint256 reward = earn(msg.sender, tokenId);
        if (pool.rewardRemain == 0 && time == 1) {
            reward = 0;
        }
        if(reward > 0) {
            uint256 bal = IERC20(tokenAddress).balanceOf(address(this));
            require(bal>=reward,"InsufficentFund");
            claimInfo[poolId.current()][tokenId] = ClaimInfo(block.timestamp,reward,msg.sender);
            data.rewardClaimed += reward;
            data.rewardPaid = 0;
            data.lastClaimed = block.timestamp;
            data.lastUpdate = block.timestamp;
            IERC20(tokenAddress).transfer(msg.sender, reward);
            emit ClaimReward(msg.sender, data.balance, reward);
        }

    }

    function upgradeTier(uint256 tokenId, uint256 tier) external {
        OwnerData storage data = ownerData[msg.sender][tokenId];
        updatePool(poolId.current());
        require(data.balance < 5, "Your NFT already in Highest tier");
        if (tier == 0) {
            if (data.balance == 2) {
                IERC20(tokenAddress).transferFrom(msg.sender, address(this),50*10**18);
                data.rewardPaid = earn(msg.sender, tokenId);
                data.balance = 5;
                if (claimInfo[poolId.current()][tokenId].claimTime == 0) {
                    data.lastUpdate = (block.timestamp).div(DAY_IN_SECONDS).add(1).mul(DAY_IN_SECONDS);
                    poolInfos[poolId.current()].totalDeposit += 3;
                    poolInfos[poolId.current()].rewardPerNFT = rewardPerDay.div(poolInfos[poolId.current()].totalDeposit);
                } else {
                    poolInfos[poolId.current()].totalDepositForNextPool += 3;
                }
            } else {
                IERC20(tokenAddress).transferFrom(msg.sender, address(this),60*10**18);
                data.rewardPaid = earn(msg.sender, tokenId);
                data.balance = 5;
                if (claimInfo[poolId.current()][tokenId].claimTime == 0) {
                    data.lastUpdate = (block.timestamp).div(DAY_IN_SECONDS).add(1).mul(DAY_IN_SECONDS);
                    poolInfos[poolId.current()].totalDeposit += 4;
                    poolInfos[poolId.current()].rewardPerNFT = rewardPerDay.div(poolInfos[poolId.current()].totalDeposit);
                } else {
                    poolInfos[poolId.current()].totalDepositForNextPool += 4;
                }
            }
        } else if (tier == 1) {
            require(data.balance < 2, "Your NFT already in Rare tier");
            IERC20(tokenAddress).transferFrom(msg.sender, address(this),10*10**18);
            data.rewardPaid = earn(msg.sender, tokenId);
            data.balance = 2;
            if (claimInfo[poolId.current()][tokenId].claimTime == 0) {
                data.lastUpdate = (block.timestamp).div(DAY_IN_SECONDS).add(1).mul(DAY_IN_SECONDS);
                poolInfos[poolId.current()].totalDeposit += 1;
                poolInfos[poolId.current()].rewardPerNFT = rewardPerDay.div(poolInfos[poolId.current()].totalDeposit);
            } else {
                poolInfos[poolId.current()].totalDepositForNextPool += 1;
            }
        }

    }

    function createNewPool(uint256 totalDeposit) internal view returns (PoolInfo memory){
        uint256 rewardPerNFT = rewardPerDay.div(totalDeposit);
        return PoolInfo(
            block.timestamp,
            totalDeposit,
            totalDeposit,
            block.timestamp,
            rewardPerDay,
            rewardPerNFT
        );
    }

    function updatePool(uint256 _poolId) internal {
        PoolInfo storage pool = poolInfos[_poolId];
        uint256 multiplier ;
        if (pool.lastRewardTime > 0) {
            multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
        }
        if (multiplier >= 1) {
            PoolInfo memory newPool = createNewPool(pool.totalDepositForNextPool);
            poolId.increment();
            poolInfos[poolId.current()] = newPool;
        } else {
            pool.lastRewardTime = block.timestamp;
        }
    }
    
    function getPoolIdCurrent() external view returns(uint256) {
        return poolId.current();
    }

    function getOwnerData(uint256 tokenId) external view returns(OwnerData memory) {
        return ownerData[msg.sender][tokenId];
    }
    // Only for test
    function blockTime() external view returns(uint256) {
        return block.timestamp;
    }
}
