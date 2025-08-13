// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/DEX.sol";
import "../src/Rayverse.sol";
import "../src/SonarTaka.sol";

contract DEXTest is Test {
    DEX dex;
    Rayverse rayverse;
    SonarTaka sonarTaka;

    address user = address(0x3);

    function setUp() public {
        // Deploy tokens from this test contract (which will have tokens)
        rayverse = new Rayverse();
        sonarTaka = new SonarTaka();

        // Deploy DEX
        dex = new DEX(address(rayverse), address(sonarTaka), address(rayverse), address(sonarTaka));

        // Give DEX contract some tokens to distribute
        rayverse.transfer(address(dex), 1_000_000e18);
        sonarTaka.transfer(address(dex), 1_000_000e18);

        // Give user some initial tokens for testing
        rayverse.transfer(user, 100_000e18);
        sonarTaka.transfer(user, 100_000e18);

        // User needs to approve DEX to spend their tokens
        vm.startPrank(user);
        rayverse.approve(address(dex), type(uint256).max);
        sonarTaka.approve(address(dex), type(uint256).max);
        vm.stopPrank();
    }

    function testGetSomeBalance() public {
        // Initially user has tokens from deployer
        assertEq(rayverse.balanceOf(user), 100_000e18);
        assertEq(sonarTaka.balanceOf(user), 100_000e18);

        // Fund user from DEX (this function gives tokens from DEX to user)
        vm.prank(user);
        dex.getSomeBalance();

        // Check that user received additional tokens from DEX
        assertEq(rayverse.balanceOf(user), 110_000e18); // 100_000 + 10_000
        assertEq(sonarTaka.balanceOf(user), 110_000e18); // 100_000 + 10_000
    }

    function testInitializeLiquidity() public {
        // First, user needs to get tokens from DEX to have balance
        vm.startPrank(user);
        dex.getSomeBalance();
        vm.stopPrank();

        // Now user can provide liquidity
        vm.startPrank(user);
        dex.initializeLiquidity(50_000, 50_000);
        vm.stopPrank();

        // Check liquidity stored in DEX
        assertEq(dex.checkRayverseLiquidity(), 50_000e18);
        assertEq(dex.checkSonarTakaLiquidity(), 50_000e18);
    }

    function testAddLiquidity() public {
        // First, user needs to get tokens from DEX to have balance
        vm.startPrank(user);
        dex.getSomeBalance();
        vm.stopPrank();

        // Initialize liquidity first
        vm.startPrank(user);
        dex.initializeLiquidity(10_000, 10_000);
        vm.stopPrank();

        // Add more liquidity
        vm.startPrank(user);
        dex.addLiquidityForRayverse(5_000);
        dex.addLiquidityForSonarTaka(5_000);
        vm.stopPrank();

        // Check liquidity stored in DEX
        assertEq(dex.checkRayverseLiquidity(), 15_000e18);
        assertEq(dex.checkSonarTakaLiquidity(), 15_000e18);
    }

    function testSwap() public {
        // First, user needs to get tokens from DEX to have balance
        vm.startPrank(user);
        dex.getSomeBalance();
        vm.stopPrank();

        // Initialize liquidity first
        vm.startPrank(user);
        dex.initializeLiquidity(10_000, 10_000);
        vm.stopPrank();

        // Perform swap
        vm.startPrank(user);
        uint256 outputAmount = dex.swapRayverseToSonarTaka(1_000);
        vm.stopPrank();

        // Check that swap was successful
        assertGt(outputAmount, 0);
    }
}
