// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


contract Airdrop is OwnableUpgradeable, UUPSUpgradeable {
    using SafeMath for uint256;

    /*================================ VARIABLES ================================*/
    uint256 constant DAY_IN_SECONDS = 86400;
    uint256 public rewardPerDay;
    address internal _nftContract;
    mapping (address=>OwnerData) private ownerData;
    uint256 public holder;
    uint256 public startDay;
    uint256 public todayClaimed;
    address public tokenAddress;
    PoolInfo public poolInfo;

    /*================================ STRUCTS ================================*/
    struct OwnerData {
        uint256 startTime;
        uint256 balance;
        uint256 rewardClaimed;
        uint256 lastClaimed;
        uint256 rewardDebt;
        uint256 rewardPaid;
        address account;
    }

    struct PoolInfo {
        uint256 totalDeposit;
        uint256 lastRewardTime;
        uint256 accRewardsPerShare;
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
        ///@dev as there is no constructor, we need to initialise the OwnableUpgradeable explicitly
        __Ownable_init();

        
    }

    function transferNFT(address from, address to, uint256 amount) external {
        require(msg.sender == _nftContract,"Only NFT contract can call");
        OwnerData storage dataFrom = ownerData[from];
        OwnerData storage dataTo = ownerData[to];

        updatePool();
        dataFrom.rewardPaid = dataFrom.balance.mul(poolInfo.accRewardsPerShare).div(1e18).sub(dataFrom.rewardDebt).add(dataFrom.rewardPaid);
        dataTo.rewardPaid = dataTo.balance.mul(poolInfo.accRewardsPerShare).div(1e18).sub(dataTo.rewardDebt).add(dataTo.rewardPaid);

        dataTo.balance += amount;
        dataFrom.balance -= amount;
        
        dataFrom.rewardDebt =  dataFrom.balance.mul(poolInfo.accRewardsPerShare).div(1e18);
        dataTo.rewardDebt =  dataTo.balance.mul(poolInfo.accRewardsPerShare).div(1e18);
        
    }
    function mintNFT(address to, uint256 amount) external {
        require(msg.sender == _nftContract,"Only NFT contract can call");
        OwnerData storage data = ownerData[to];

        updatePool();
        data.rewardPaid = data.balance.mul(poolInfo.accRewardsPerShare).div(1e18).sub(data.rewardDebt).add(data.rewardPaid);

        data.balance += amount;
        poolInfo.totalDeposit += amount;

        data.rewardDebt =  data.balance.mul(poolInfo.accRewardsPerShare).div(1e18);
    }
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
       uint256 multiplier = _to.sub(_from).div(DAY_IN_SECONDS);
       return multiplier+1;
    }
    function pendingReward() public view returns(uint256) {
        OwnerData memory data = ownerData[msg.sender];
        uint256 accRewardsPerShare = poolInfo.accRewardsPerShare;
        uint256 multiplier = getMultiplier(poolInfo.lastRewardTime, block.timestamp);
        uint256 tokenReward = rewardPerDay * multiplier;
        accRewardsPerShare = accRewardsPerShare.add(tokenReward.mul(1e18).div(poolInfo.totalDeposit));
        return data.balance.mul(accRewardsPerShare).div(1e18).sub(data.rewardDebt);
    }
    function claimAirdrop() external {
        OwnerData storage data = ownerData[msg.sender];
        require(block.timestamp/DAY_IN_SECONDS - data.lastClaimed/DAY_IN_SECONDS >=1, "You already Claimed");

        updatePool();
        uint256 reward = data.balance.mul(poolInfo.accRewardsPerShare).div(1e18).sub(data.rewardDebt).add(data.rewardPaid);
        if(reward > 0) {
            uint256 bal = IERC20(tokenAddress).balanceOf(address(this));
            require(bal>=reward,"InsufficentFund");
        }

        data.rewardClaimed += reward;
        data.rewardPaid = 0;

        emit ClaimReward(msg.sender, data.balance, reward);
    }

    function updatePool() public {

        uint256 supply = poolInfo.totalDeposit;
        if (supply == 0) {
            poolInfo.lastRewardTime = block.timestamp;
            return;
        }

        uint256 multiplier = getMultiplier(poolInfo.lastRewardTime, block.timestamp);
        uint256 tokenReward = rewardPerDay * multiplier;
        poolInfo.accRewardsPerShare = poolInfo.accRewardsPerShare.add(tokenReward.mul(1e18).div(supply));
        poolInfo.lastRewardTime = block.timestamp;
    }

    function getOwnerData() external view returns(OwnerData memory) {
        return ownerData[msg.sender];
    }
}
