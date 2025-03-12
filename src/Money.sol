// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// Imports
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// Contracts

contract Money is ERC20, Ownable {
    // Types

    //Attributs
    // Storage
    address private admin;
    // Events
    // Errors

    error IncorrectEtherAmount(uint256 etherAmount);

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {}

    function mint(address target_, uint256 value_) external onlyOwner {
        _mint(target_, value_);
    }

    function payToMint(address target_) external payable {
        require(msg.value == 1 ether, IncorrectEtherAmount(msg.value));
        _mint(target_, 100);
    }
}
