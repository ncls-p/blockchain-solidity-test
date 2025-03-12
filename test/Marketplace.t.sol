// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import {Test, console} from "forge-std/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";

contract MarketplaceTest is Test {
    Marketplace public marketplace;
    address admin;
    address user;

    function setUp() public {
        admin = address(0x123);
        user = address(0x456);

        // Use the admin address for deployment
        vm.startPrank(admin);

        marketplace = new Marketplace("Market Token", "MTK"); // deploy the contract

        vm.stopPrank();
    }

    function testConstructor() public view {
        assertEq("Market Token", marketplace.name(), "Token name was not correctly initialized");
        assertEq("MTK", marketplace.symbol(), "Token symbol was not correctly initialized");
    }

    function testCreateItem() public {
        // Only owner should be able to create an item
        vm.startPrank(admin);
        marketplace.createItem("Test Item", 100);
        vm.stopPrank();

        Marketplace.Item memory item = marketplace.getItem(0);
        assertEq("Test Item", item.name, "Item name was not set correctly");
        assertEq(100, item.price, "Item price was not set correctly");
        assertEq(false, item.listed, "Item should not be listed by default");
        assertEq(address(marketplace), item.owner, "Item owner should be the marketplace");
    }

    function testCreateItemRequiresPriceGreaterThanZero() public {
        vm.startPrank(admin);
        
        // This should revert
        vm.expectRevert("IncorrectAmount");
        marketplace.createItem("Zero Price Item", 0);
        
        vm.stopPrank();
    }

    function testOnlyOwnerCanCreateItem() public {
        // Non-owner should not be able to create an item
        vm.startPrank(user);
        
        // This should revert with an Ownable error
        vm.expectRevert();
        marketplace.createItem("User Item", 100);
        
        vm.stopPrank();
    }

    function testGetItem() public {
        // Create an item first
        vm.startPrank(admin);
        marketplace.createItem("Retrievable Item", 150);
        vm.stopPrank();

        // Get the item and validate its properties
        Marketplace.Item memory item = marketplace.getItem(0);
        assertEq("Retrievable Item", item.name, "Retrieved item has incorrect name");
        assertEq(150, item.price, "Retrieved item has incorrect price");
        assertEq(false, item.listed, "Retrieved item has incorrect listing status");
    }

    function testGetItem2() public {
        // Create an item first
        vm.startPrank(admin);
        marketplace.createItem("Second Item", 200);
        vm.stopPrank();

        // Get the item using the getItem2 function
        (string memory name, uint256 price, uint256 timestamp) = marketplace.getItem2(0);
        
        assertEq("Second Item", name, "Retrieved item name is incorrect");
        assertEq(200, price, "Retrieved item price is incorrect");
        assertTrue(timestamp > 0, "Retrieved item timestamp should be set");
    }

    function testListItem() public {
        // Create an item first
        vm.startPrank(admin);
        marketplace.createItem("Listable Item", 300);
        
        // List the item
        marketplace.listItem(0);
        vm.stopPrank();

        // Verify the item is listed
        Marketplace.Item memory item = marketplace.getItem(0);
        assertTrue(item.listed, "Item should be listed after calling listItem");
    }

    function testOnlyOwnerCanListItem() public {
        // Create an item first
        vm.startPrank(admin);
        marketplace.createItem("Owner Only Item", 400);
        vm.stopPrank();

        // Non-owner tries to list the item
        vm.startPrank(user);
        
        // This should revert with an Ownable error
        vm.expectRevert();
        marketplace.listItem(0);
        
        vm.stopPrank();
    }

    function testBuyItem() public {
        // Set up: create an item, list it, and mint tokens to the user
        vm.startPrank(admin);
        marketplace.createItem("Buyable Item", 500);
        marketplace.listItem(0);
        marketplace.mint(user, 1000); // Mint tokens to the user
        vm.stopPrank();

        // User buys the item
        vm.startPrank(user);
        marketplace.buyItem(0);
        vm.stopPrank();

        // Verify ownership has changed
        Marketplace.Item memory item = marketplace.getItem(0);
        assertEq(user, item.owner, "Item owner should be the user after purchase");
        
        // Verify token balances
        assertEq(marketplace.balanceOf(user), 500, "User should have 500 tokens left");
        assertEq(marketplace.balanceOf(address(marketplace)), 500, "Marketplace should have received 500 tokens");
    }

    function testCannotBuyUnlistedItem() public {
        // Set up: create an item but don't list it, and mint tokens to the user
        vm.startPrank(admin);
        marketplace.createItem("Unlisted Item", 500);
        marketplace.mint(user, 1000);
        vm.stopPrank();

        // User tries to buy unlisted item
        vm.startPrank(user);
        
        // This should revert
        vm.expectRevert("ERROR");
        marketplace.buyItem(0);
        
        vm.stopPrank();
    }

    function testCannotBuyWithoutEnoughTokens() public {
        // Set up: create an item and list it, but don't mint enough tokens
        vm.startPrank(admin);
        marketplace.createItem("Expensive Item", 1000);
        marketplace.listItem(0);
        marketplace.mint(user, 500); // Not enough tokens
        vm.stopPrank();

        // User tries to buy item without enough tokens
        vm.startPrank(user);
        
        // This should revert
        vm.expectRevert("Error 2");
        marketplace.buyItem(0);
        
        vm.stopPrank();
    }
}
