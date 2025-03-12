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

    function testTokenSymbolName() public {
        assertEq(money.name(), "$MONEY$");
        assertEq(money.symbol(), "$$$");
    }
}
