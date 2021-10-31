pragma solidity >=0.8.0;

// SPDX-License-Identifier: GPL-3.0

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/1b27c13096d6e4389d62e7b0766a1db53fbb3f1b/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/1b27c13096d6e4389d62e7b0766a1db53fbb3f1b/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./2_Owner.sol";

contract BattleRoyal is Owner{
    
    event TransferReceived(address _from, uint _amount);
    event TransferSent(address _from, address _destAddr, uint _amount);
    
    using SafeMath for uint256;
    
    uint public gasValue = 0;
    
    uint public counter = 0;
    
    struct gameInfo{
        uint minAmount;// Min amount each player is required to contribute.
        uint capacity; // Number of players required for the game to start.
        bool gameFinished;
        uint gasfee;// gas fee is in wei. Taking the gasfee value from the owner but will pay from the fund.
        IERC20 mtoken;
        uint curCapacity;
        uint amntCollected;
        // Map is used so we can find the address very fast.
        mapping(address => uint) adrsledger; // an array of the addresses of the people who have deposited the fund. Can make the value of map to store the points of the user
        address champion;
    }
    
    gameInfo[] public gameList;
    
    constructor() payable{
        gasValue = gasValue.add(msg.value);
    }
    
    function increaseGas() isOwner payable external{
        gasValue = gasValue.add(msg.value);
    } 
    
    function creategame(uint amountMin, uint gasCost, uint gamers, IERC20 tokenAddress) isOwner external returns (uint temp) {// it returns the token id of the game which will be used later
        
        temp = counter;
        gameList.push();
        gameList[counter].minAmount = amountMin;
        gameList[counter].capacity = gamers;
        gameList[counter].gasfee = gasCost;
        gameList[counter].gameFinished = false;
        gameList[counter].curCapacity = 0;
        gameList[counter].amntCollected = 0;
        gameList[counter].mtoken = tokenAddress;
        counter+=1;
    }
    
    // the contract address can be populated by API.
    function entryFee (IERC20 token, address contractAddress, uint256 amount, uint id) external{
        require(amount >= gameList[id].minAmount, "Amount being transferred is less than the entry fee");
        require(gameList[id].curCapacity < gameList[id].capacity, "The game is full");
        require(gameList[id].adrsledger[msg.sender] == 0, "Gamer has already registered for the game");
        require(gameList[id].mtoken == token, "Mismatch in the entry token");
        require(gameList[id].gameFinished == false, "Game has already ended");
        token.transferFrom(msg.sender, contractAddress, amount);// First approve must have been called.
        gameList[id].amntCollected = gameList[id].amntCollected.add(amount);
        gameList[id].curCapacity = gameList[id].curCapacity.add(1);
        gameList[id].adrsledger[msg.sender] = 1;
        emit TransferReceived(msg.sender, amount);
    }
    
    function declareWinner(uint id, address vijeta) isOwner external {
        require(gameList[id].gameFinished == true, "Game is still going on");
        gameList[id].champion = vijeta; //some logic at the front end which will send the winner address.
    }
    
    function endGame(uint id) isOwner external{
        gameList[id].gameFinished = true;
    }
    
    function sendRewardGas(IERC20 token, uint id) external{
        require(gameList[id].gameFinished == true, "Sorry, the game is still running");
        require(gameList[id].mtoken == token, "Mismatch in the entry token");
        // TODO: Send in wei so that smaller decimals can be acheived.
        // TODO: Make all the transaction with smaller unit in wei from gas to amount.
        // DONE2: Here the calculation is being done in wei.
        // Assume the amntPrms is in wei and the gas is also in wei then.
        uint rewardAmnt = gameList[id].amntCollected.div(2).sub(gameList[id].gasfee);
        uint256 erc20balance = token.balanceOf(address(this));
        require(rewardAmnt <= erc20balance, "balance is low");
        token.transfer(gameList[id].champion, rewardAmnt);
        emit TransferSent(msg.sender, gameList[id].champion, rewardAmnt);
        token.transfer(owner, rewardAmnt);
        emit TransferSent(msg.sender, owner, rewardAmnt);
    }
    
    // The IERC20 token address can be sent by API as it can have the local copy of the ledger.
    function sendRewardNoGas(IERC20 token, uint id) external{
        require(gameList[id].gameFinished == true, "Sorry, the game is still running");
        require(gameList[id].mtoken == token, "Mismatch in the entry token");
        // TODO: Send in wei so that smaller decimals can be acheived.
        // TODO: Make all the transaction with smaller unit in wei from gas to amount.
        // DONE2: Here the calculation is being done in wei.
        // Assume the amntPrms is in wei and the gas is also in wei then.
        uint rewardAmnt = gameList[id].amntCollected.div(2);
        uint256 erc20balance = token.balanceOf(address(this));
        require(rewardAmnt <= erc20balance, "balance is low");
        token.transfer(gameList[id].champion, rewardAmnt);
        emit TransferSent(msg.sender, gameList[id].champion, rewardAmnt);
        token.transfer(owner, rewardAmnt);
        emit TransferSent(msg.sender, owner, rewardAmnt);
    }
}