// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


/*
Challenge
Your task is to create a ERC20 token and deploy it on the Avalanche network for Degen Gaming. The smart contract should have the following functionality:

Minting new tokens: The platform should be able to create new tokens and distribute them to players as rewards. Only the owner can mint tokens.
Transferring tokens: Players should be able to transfer their tokens to others.
Redeeming tokens: Players should be able to redeem their tokens for items in the in-game store.
Checking token balance: Players should be able to check their token balance at any time.
Burning tokens: Anyone should be able to burn tokens, that they own, that are no longer needed.
*/

contract DegenToken is ERC20 {

    address public owner;

    

    mapping (address => bool)  redeemedBulletproofVest;

    mapping (address => bool)  redeemedGun;

    mapping (address => bool)  redeemedMap;

    mapping (address => bool)  canPlayGame;



    // custom errors
    error NotOwner();
    error InsufficientBalance();
    error InvalidItem();
    error RedeemGunFirst();
    error RedeemBulletProofVestFirst();


    constructor() ERC20("Degen", "DGN") {
        owner = msg.sender;
    }

    // Private function to check to restrict a function 
    // used in place of modifiers to save gas 
    function onlyOwner() private view {
        if (msg.sender != owner)
            revert NotOwner();
    }

    // Check if player has enough token
     // used in place of modifiers to save gas 
    function hasEnoughDegenTokens(uint256 _amount) private view {
        if (balanceOf(msg.sender) < _amount)
            revert InsufficientBalance();
    }

    // mint degenToken to player
    function mintDegenTokens(address _player, uint256 _amount) public {
        onlyOwner();
        _mint(_player, _amount);
    }

    // Player burn degen token
    function burnDegenTokens(uint256 amount) public {
        hasEnoughDegenTokens(amount);
        _burn(msg.sender, amount);
    }

    // Player transfer degen token 
    function transferDegenToken(address to, uint256 amount)
        public
        returns (bool)
    {
        hasEnoughDegenTokens(amount);
        _transfer(msg.sender, to, amount);
        return true;
    }

    // Get balance of player
    function getDegenBalance(address _playerAddress) public view returns (uint256) {
        return super.balanceOf(_playerAddress);
    }

    // view redeemable items in marketplace
    function viewMarketplace() external pure returns (string memory) {
        return "Marketplace: 1. BulletProof Vest - 15DGN, 2. Gun - 25DGN, 3. Map - 50DGN ";
    }

    // redeem item from marketplace
    function redeemMarketPlaceItem(uint8 _itemToredeem) external returns (bool) {

        if (_itemToredeem == 1) {

            if (this.balanceOf(msg.sender) < 15) revert InsufficientBalance();
            
            approve(msg.sender, 15);
            
            transferFrom(msg.sender, owner, 15);
            
            redeemedBulletproofVest[msg.sender] = true;
            
            return true;
        
        } else if (_itemToredeem == 2) {
            
            if (!redeemedBulletproofVest[msg.sender]) revert RedeemBulletProofVestFirst();

            if (this.balanceOf(msg.sender) < 25) revert InsufficientBalance();
            
            approve(msg.sender, 25);
            
            transferFrom(msg.sender, owner, 25);
            
            redeemedGun[msg.sender] = true;
            
            return true;

        } else if (_itemToredeem == 3) {

            if (!redeemedGun[msg.sender]) revert RedeemGunFirst();
           
            if (this.balanceOf(msg.sender) < 50) revert InsufficientBalance();
            
            approve(msg.sender, 50);
            
            transferFrom(msg.sender, owner, 50);
            
            redeemedMap[msg.sender] = true;

            canPlayGame[msg.sender] = true;
                        
            return true;

        } else {

            revert InvalidItem();
        
        }
    }

    function canUserPlay() external view  returns (bool) {
        return canPlayGame[msg.sender];
    }
}
