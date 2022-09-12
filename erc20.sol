//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract SuperToken is ERC20 {
   
    struct stakeHolder {
       address _adr;
        uint256 _amountStaked;
        uint256 _timeOfStaking;
    } 
    stakeHolder[] stakeholders;

    // mapping to track users who have staked
    mapping(address => stakeHolder ) public stakes;
    
   
    // struct to store details of token seller
    struct listing {
        uint256 _id;
        address _adr;
        uint256 tokens4Sale;
        uint256 tokenPrice;
    }
    listing[] Listing;

    //mapping to store ID against listings
    mapping (uint256 => listing) public allListings;
    uint256 public id;

    constructor() ERC20("SuperToken","ST") {
        _mint(msg.sender,10000000 * 10**18); //minting into owner wallet
    }

    // custom transfer function burning 2% of the transaction cost
     function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
       uint256 burnAmount = amount * 2 / 100;
        _burn(owner, burnAmount );
        amount = amount - burnAmount;
        _transfer(owner, to, amount);
        return true;
    }
  
    // function to stake tokens
    function staking(uint256 amount) public {
         uint256 timestamp = block.timestamp;
         transfer(address(this), amount);
         stakes[msg.sender] = stakeHolder(msg.sender,amount,timestamp);
         stakeholders.push(stakeHolder(msg.sender,amount,timestamp));
    }

    // for getting reward per amount and time staked
    function getReward() public{
        uint256 currentTimestamp = block.timestamp;
        uint256 stakingTime  = (currentTimestamp - stakes[msg.sender]._timeOfStaking);
        stakingTime = stakingTime ;  
        // require( stakingTime >= 1);
        uint256 rewardAmount = (stakes[msg.sender]._amountStaked) * 2/100000 *stakingTime ; 
   
        _transfer(address(this),msg.sender, rewardAmount);
     
    }

    // for unstaking tokens
    function unstake() public {
         _transfer(address(this),msg.sender, stakes[msg.sender]._amountStaked);
        
    }

    // to get all the addresses that have staked
    function getStakeHolders() public view returns  (stakeHolder [] memory){
        return stakeholders;
    }

    // for users to create listing
    function sellTokens(uint256 noOfTokens, uint256 tokenPrice) public {
     require( msg.sender != address(0));
     require( noOfTokens < balanceOf(msg.sender), "You donot have enough tokens to sell");
     id++;
     allListings[id] = listing(id,msg.sender,noOfTokens,tokenPrice);
     Listing.push(listing(id,msg.sender,noOfTokens,tokenPrice));
       
    }

    // get the list of tokens for sale
    function getListings() public view returns (listing [] memory) {
        return Listing;
    }
    
    // for buying tokens through listing
    function buyToken(uint256 _id, uint256 _amount) public {
        
        if (_amount < allListings[_id].tokenPrice) revert();
        _transfer(allListings[_id]._adr,msg.sender, allListings[_id].tokens4Sale);
        transfer(allListings[_id]._adr, _amount);
        allListings[_id] = listing(0,address(0),0,0);
        uint256 index = 0;
        uint256 listLength = Listing.length;
        for ( uint256 i = 0; i < listLength; i++){
            if ( _id == Listing[i]._id){
                index = i;
            }
        }
        Listing[index] = Listing[listLength - 1];
        Listing.pop();

      

    }

    
}

