// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Money} from "./Money.sol";

contract Marketplace is Money {
        //  Types
        struct Item {
            string name;
            uint256 price;
            uint256 timestamp;
            bool listed;
            address owner;
        }
        mapping(uint256 id => Item) private items;
        uint256 private itemCounter;

    constructor(string memory name_, string memory symbol) Money(name_, symbol) {
    
    }
    

    function createItem(string calldata name_, uint256 price_) external onlyOwner {
        require(price_ > 0, "IncorrectAmount");
        Item memory item = Item(name_, price_, block.timestamp, false, address(this));
        items[itemCounter] = item;

        itemCounter++;
    }

    function getItem(uint256 id_) public view returns(Item memory){
        return items[id_];
    }

    function getItem2(uint256 id_) public view returns(string memory, uint256, uint256){
        return (items[id_].name, items[id_].price, items[id_].timestamp);
    }

    function listItem(uint256 id_) external onlyOwner(){
        items[id_].listed = true;
    }

    function buyItem(uint256 id_) external {
        require(items[id_].listed, "ERROR");
        require(balanceOf(msg.sender) >= items[id_].price, "Error 2");

        items[id_].owner = msg.sender;
        transfer(address(this), items[id_].price);
    }
}
