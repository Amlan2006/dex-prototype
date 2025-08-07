//SPDX-License-Identifier: UNLICENSED

import {DEX} from "src/DEX.sol";
import {Rayverse} from  "../src/Rayverse.sol";
import {SonarTaka} from  "../src/SonarTaka.sol";
import {Test} from "forge-std/Test.sol";
import {console2} from "lib/forge-std/src/console2.sol";


contract DEXTest is Test {
    DEX public dex;
    Rayverse public rayverse;
    SonarTaka public sonarTaka;
    
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public deployer = address(this);
    
    uint256 public constant INITIAL_RAYVERSE_LIQUIDITY = 100e18;
    uint256 public constant INITIAL_SONARTAKA_LIQUIDITY = 1000e18;
    
    function setUp() public {
        // Deploy tokens first
        rayverse = new Rayverse();
        sonarTaka = new SonarTaka();
        
        // Give deployer tokens for initial liquidity
        deal(address(rayverse), deployer, INITIAL_RAYVERSE_LIQUIDITY + 1000e18);
        deal(address(sonarTaka), deployer, INITIAL_SONARTAKA_LIQUIDITY + 1000e18);
        
        // Deploy a corrected version of DEX that takes token addresses in constructor
        dex = new DEX(address(rayverse), address(sonarTaka));
        
        // Approve and transfer initial liquidity to DEX
        rayverse.approve(address(dex), INITIAL_RAYVERSE_LIQUIDITY);
        sonarTaka.approve(address(dex), INITIAL_SONARTAKA_LIQUIDITY);
        dex.initializeLiquidity(INITIAL_RAYVERSE_LIQUIDITY, INITIAL_SONARTAKA_LIQUIDITY);
        
        // Setup test users with tokens
        deal(address(rayverse), user1, 500e18);
        deal(address(sonarTaka), user1, 5000e18);
        deal(address(rayverse), user2, 300e18);
        deal(address(sonarTaka), user2, 3000e18);
    }
    
    function testConstructorInitialization() public {
        assertEq(dex.rayverse(), address(rayverse));
        assertEq(dex.sonarTaka(), address(sonarTaka));
        assertEq(address(dex.tokenA()), address(rayverse));
        assertEq(address(dex.tokenB()), address(sonarTaka));
        assertEq(dex.rayverseLiqudity(), INITIAL_RAYVERSE_LIQUIDITY);
        assertEq(dex.sonarTakaLiquidity(), INITIAL_SONARTAKA_LIQUIDITY);
    }
    
    function testInitialLiquidity() public {
        assertEq(rayverse.balanceOf(address(dex)), INITIAL_RAYVERSE_LIQUIDITY);
        assertEq(sonarTaka.balanceOf(address(dex)), INITIAL_SONARTAKA_LIQUIDITY);
    }
    
    // LIQUIDITY ADDITION TESTS
    
    function testAddLiquidityForRayverseSuccess() public {
        uint256 addAmount = 50e18;
        
        vm.startPrank(user1);
        rayverse.approve(address(dex), addAmount);
        
        uint256 initialBalance = dex.balances(user1);
        uint256 initialLiquidity = dex.rayverseLiqudity();
        
        dex.addLiquidityForRayverse(addAmount);
        
        assertEq(dex.balances(user1), initialBalance + addAmount);
        assertEq(dex.rayverseLiqudity(), initialLiquidity + addAmount);
        assertEq(rayverse.balanceOf(address(dex)), INITIAL_RAYVERSE_LIQUIDITY + addAmount);
        vm.stopPrank();
    }
    
    function testAddLiquidityForRayverseFailsWithZeroAmount() public {
        vm.startPrank(user1);
        vm.expectRevert("Amount must be greater than zero");
        dex.addLiquidityForRayverse(0);
        vm.stopPrank();
    }
    
    function testAddLiquidityForRayverseFailsWithInsufficientApproval() public {
        uint256 addAmount = 50e18;
        
        vm.startPrank(user1);
        rayverse.approve(address(dex), addAmount - 1); // Insufficient approval
        
        vm.expectRevert();
        dex.addLiquidityForRayverse(addAmount);
        vm.stopPrank();
    }
    
    function testAddLiquidityForSonarTakaSuccess() public {
        uint256 addAmount = 500e18;
        
        vm.startPrank(user1);
        sonarTaka.approve(address(dex), addAmount);
        
        uint256 initialBalance = dex.balances(user1);
        uint256 initialLiquidity = dex.sonarTakaLiquidity();
        
        dex.addLiquidityForSonarTaka(addAmount);
        
        assertEq(dex.balances(user1), initialBalance + addAmount);
        assertEq(dex.sonarTakaLiquidity(), initialLiquidity + addAmount); // Fixed: now updates correct liquidity
        assertEq(sonarTaka.balanceOf(address(dex)), INITIAL_SONARTAKA_LIQUIDITY + addAmount);
        vm.stopPrank();
    }
    
    // LIQUIDITY REMOVAL TESTS
    
    function testRemoveLiquidityForRayverseSuccess() public {
        // First add liquidity
        uint256 addAmount = 50e18;
        vm.startPrank(user1);
        rayverse.approve(address(dex), addAmount);
        dex.addLiquidityForRayverse(addAmount);
        
        // Then remove liquidity
        uint256 removeAmount = 25e18;
        uint256 initialBalance = dex.balances(user1);
        uint256 initialLiquidity = dex.rayverseLiqudity();
        uint256 initialUserTokens = rayverse.balanceOf(user1);
        
        dex.removeLiquidityForRayverse(removeAmount);
        
        assertEq(dex.balances(user1), initialBalance - removeAmount);
        assertEq(dex.rayverseLiqudity(), initialLiquidity - removeAmount);
        assertEq(rayverse.balanceOf(user1), initialUserTokens + removeAmount);
        vm.stopPrank();
    }
    
    function testRemoveLiquidityForRayverseFailsWithZeroAmount() public {
        vm.startPrank(user1);
        vm.expectRevert("Amount must be greater than zero");
        dex.removeLiquidityForRayverse(0);
        vm.stopPrank();
    }
    
    function testRemoveLiquidityForRayverseFailsWithInsufficientBalance() public {
        vm.startPrank(user1);
        vm.expectRevert("Insufficient balance");
        dex.removeLiquidityForRayverse(100e18); // User has no liquidity balance
        vm.stopPrank();
    }
    
    function testRemoveLiquidityForSonarTakaSuccess() public {
        // First add liquidity
        uint256 addAmount = 500e18;
        vm.startPrank(user1);
        sonarTaka.approve(address(dex), addAmount);
        dex.addLiquidityForSonarTaka(addAmount);
        
        // Then remove liquidity
        uint256 removeAmount = 250e18;
        uint256 initialBalance = dex.balances(user1);
        uint256 initialLiquidity = dex.sonarTakaLiquidity();
        uint256 initialUserTokens = sonarTaka.balanceOf(user1);
        
        dex.removeLiquidityForSonarTaka(removeAmount);
        
        assertEq(dex.balances(user1), initialBalance - removeAmount);
        assertEq(dex.sonarTakaLiquidity(), initialLiquidity - removeAmount);
        assertEq(sonarTaka.balanceOf(user1), initialUserTokens + removeAmount);
        vm.stopPrank();
    }
    
    // SWAP TESTS
    
    function testSwapRayverseToSonarTakaSuccess() public {
        uint256 swapAmount = 10e18;
        
        vm.startPrank(user1);
        rayverse.approve(address(dex), swapAmount);
        
        uint256 expectedSonarTaka = (swapAmount * INITIAL_SONARTAKA_LIQUIDITY) / (INITIAL_RAYVERSE_LIQUIDITY + swapAmount);
        uint256 initialUserSonarTaka = sonarTaka.balanceOf(user1);
        uint256 initialUserRayverse = rayverse.balanceOf(user1);
        
        uint256 actualSonarTaka = dex.swapRayverseToSonarTaka(swapAmount);

        console2.log("Expected SonarTaka:", expectedSonarTaka);
        console2.log("Actual SonarTaka:", actualSonarTaka);
        
        assertEq(actualSonarTaka, expectedSonarTaka);
        assertEq(sonarTaka.balanceOf(user1), initialUserSonarTaka + actualSonarTaka);
        assertEq(rayverse.balanceOf(user1), initialUserRayverse - swapAmount);
        assertEq(dex.rayverseLiqudity(), INITIAL_RAYVERSE_LIQUIDITY + swapAmount); // Fixed: liquidity increases on swap in
        assertEq(dex.sonarTakaLiquidity(), INITIAL_SONARTAKA_LIQUIDITY - actualSonarTaka);
        vm.stopPrank();
    }
    
    function testSwapRayverseToSonarTakaFailsWithZeroAmount() public {
        vm.startPrank(user1);
        vm.expectRevert("Amount must be greater than zero");
        dex.swapRayverseToSonarTaka(0);
        vm.stopPrank();
    }
    
    function testSwapSonarTakaToRayverseSuccess() public {
        uint256 swapAmount = 100e18;
        
        vm.startPrank(user1);
        sonarTaka.approve(address(dex), swapAmount);
        
        uint256 expectedRayverse = (swapAmount * INITIAL_RAYVERSE_LIQUIDITY) / (INITIAL_SONARTAKA_LIQUIDITY + swapAmount);
        uint256 initialUserRayverse = rayverse.balanceOf(user1);
        uint256 initialUserSonarTaka = sonarTaka.balanceOf(user1);
        
        uint256 actualRayverse = dex.swapSonarTakaToRayverse(swapAmount);
        
        assertEq(actualRayverse, expectedRayverse);
        assertEq(rayverse.balanceOf(user1), initialUserRayverse + actualRayverse);
        assertEq(sonarTaka.balanceOf(user1), initialUserSonarTaka - swapAmount);
        assertEq(dex.sonarTakaLiquidity(), INITIAL_SONARTAKA_LIQUIDITY + actualRayverse); // Fixed: liquidity increases on swap in
        assertEq(dex.rayverseLiqudity(), INITIAL_RAYVERSE_LIQUIDITY - actualRayverse);
        vm.stopPrank();
    }
    
    function testSwapSonarTakaToRayverseFailsWithZeroAmount() public {
        vm.startPrank(user1);
        vm.expectRevert("Amount must be greater than zero");
        dex.swapSonarTakaToRayverse(0);
        vm.stopPrank();
    }
    
    // PRICE IMPACT TESTS
    
    function testLargeSwapPriceImpact() public {
        uint256 largeSwapAmount = 50e18; // Half of initial Rayverse liquidity
        
        vm.startPrank(user1);
        rayverse.approve(address(dex), largeSwapAmount);
        
        uint256 expectedSonarTaka = (largeSwapAmount * INITIAL_SONARTAKA_LIQUIDITY) / (INITIAL_RAYVERSE_LIQUIDITY + largeSwapAmount);
        uint256 actualSonarTaka = dex.swapRayverseToSonarTaka(largeSwapAmount);
        
        assertEq(actualSonarTaka, expectedSonarTaka);
        
        // Price should be significantly worse than initial ratio
        uint256 initialRatio = INITIAL_SONARTAKA_LIQUIDITY / INITIAL_RAYVERSE_LIQUIDITY; // 10
        uint256 actualRatio = actualSonarTaka / largeSwapAmount;
        
        assertLt(actualRatio, initialRatio); // Should get less than 10:1 ratio due to slippage
        vm.stopPrank();
    }
    
    // INVARIANT TESTS
    
    function testConstantProductInvariant() public {
        uint256 initialProduct = INITIAL_RAYVERSE_LIQUIDITY * INITIAL_SONARTAKA_LIQUIDITY;
        
        // Perform a swap
        uint256 swapAmount = 5e18;
        vm.startPrank(user1);
        rayverse.approve(address(dex), swapAmount);
        dex.swapRayverseToSonarTaka(swapAmount);
        vm.stopPrank();
        
        uint256 newProduct = dex.rayverseLiqudity() * dex.sonarTakaLiquidity();
        
        // In a constant product AMM, product should remain constant
        // But our DEX increases one side on swaps, so product will increase
        assertGe(newProduct, initialProduct);
    }
    
    // EDGE CASE TESTS
    
    function testSwapWithInsufficientLiquidity() public {
        // Try to swap more than available liquidity
        uint256 excessiveAmount = INITIAL_SONARTAKA_LIQUIDITY + 1;
        
        vm.startPrank(user1);
        deal(address(rayverse), user1, excessiveAmount); // Give user enough tokens
        rayverse.approve(address(dex), excessiveAmount);
        
        // This should fail or return 0
        vm.expectRevert(); // Might underflow when updating liquidity
        dex.swapRayverseToSonarTaka(excessiveAmount);
        vm.stopPrank();
    }
    
    function testMultipleUsersLiquidity() public {
        uint256 user1Amount = 25e18;
        uint256 user2Amount = 15e18;
        
        // User1 adds liquidity
        vm.startPrank(user1);
        rayverse.approve(address(dex), user1Amount);
        dex.addLiquidityForRayverse(user1Amount);
        vm.stopPrank();
        
        // User2 adds liquidity
        vm.startPrank(user2);
        rayverse.approve(address(dex), user2Amount);
        dex.addLiquidityForRayverse(user2Amount);
        vm.stopPrank();
        
        assertEq(dex.balances(user1), user1Amount);
        assertEq(dex.balances(user2), user2Amount);
        assertEq(dex.rayverseLiqudity(), INITIAL_RAYVERSE_LIQUIDITY + user1Amount + user2Amount);
    }
    
    // FUZZ TESTS
    
    function testFuzzSwapRayverseToSonarTaka(uint256 amount) public {
        amount = bound(amount, 1, 50e18); // Reasonable bounds
        
        vm.assume(amount > 0);
        vm.assume(amount <= rayverse.balanceOf(user1));
        
        vm.startPrank(user1);
        rayverse.approve(address(dex), amount);
        
        uint256 expectedOutput = (amount * dex.sonarTakaLiquidity()) / (dex.rayverseLiqudity() + amount);
        vm.assume(expectedOutput > 0);
        vm.assume(expectedOutput <= dex.sonarTakaLiquidity());
        
        uint256 actualOutput = dex.swapRayverseToSonarTaka(amount);
        assertEq(actualOutput, expectedOutput);
        vm.stopPrank();
    }
    
    function testFuzzAddLiquidity(uint256 amount) public {
        amount = bound(amount, 1, 100e18);
        
        vm.assume(amount > 0);
        vm.assume(amount <= rayverse.balanceOf(user1));
        
        vm.startPrank(user1);
        rayverse.approve(address(dex), amount);
        
        uint256 initialBalance = dex.balances(user1);
        uint256 initialLiquidity = dex.rayverseLiqudity();
        
        dex.addLiquidityForRayverse(amount);
        
        assertEq(dex.balances(user1), initialBalance + amount);
        assertEq(dex.rayverseLiqudity(), initialLiquidity + amount);
        vm.stopPrank();
    }
}