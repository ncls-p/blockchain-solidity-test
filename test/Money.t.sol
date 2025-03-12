// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import {Test, console} from "forge-std/Test.sol";
import {Money} from "../src/Money.sol";
contract MoneyTest is Test {
    Money public money;
    address admin;
    address user;
    function setUp() public {
        admin = address(0x123);
        user = address(0x456);
        // On utilise de force l'adresse de l'admin
        vm.startPrank(admin);
        money = new Money("$MONEY$", "$$$"); // on déploie le contrat
        vm.stopPrank();
    }
    function testTokenSymbolName() public view {
        assertEq("$MONEY$", money.name(), "Le nom du token est mal initialise");
        assertEq(
            "$$$",
            money.symbol(),
            "Le symbole du token est mal initialise"
        );
    }
    
    /// Test to verify that only admin can mint 1000 tokens
    function testOnlyAdminCanMint1000() public {
        // Admin can mint tokens
        vm.startPrank(admin);
        money.mint(admin, 1000);
        vm.stopPrank();
        
        // User cannot mint tokens - should revert
        vm.startPrank(user);
        vm.expectRevert();
        money.mint(user, 1000);
        vm.stopPrank();
        
        assertEq(money.balanceOf(admin), 1000, "Admin balance should be 1000");
        assertEq(money.balanceOf(user), 0, "User balance should be 0");
    }
}
