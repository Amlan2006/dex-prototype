// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

// Corrected DEX contract
contract DEX {
    using SafeERC20 for IERC20;
    
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public rayverseLiquidity;
    uint256 public sonarTakaLiquidity;
    
    mapping(address => uint256) public balances;
    mapping(address => uint256) public liquidityRayverse;
    mapping(address => uint256) public liquiditySonarTaka;
    
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }
    
    function initializeLiquidity(uint256 _rayverseAmount, uint256 _sonarTakaAmount) external {
        require(rayverseLiquidity == 0 && sonarTakaLiquidity == 0, "Already initialized");
        require(_rayverseAmount > 0 && _sonarTakaAmount > 0, "Amount must be greater than zero");
        
        // Check allowances
        require(tokenA.allowance(msg.sender, address(this)) >= _rayverseAmount * 1e18, "Insufficient Rayverse allowance");
        require(tokenB.allowance(msg.sender, address(this)) >= _sonarTakaAmount * 1e18, "Insufficient SonarTaka allowance");
        
        // Transfer tokens
        tokenA.safeTransferFrom(msg.sender, address(this), _rayverseAmount * 1e18);
        tokenB.safeTransferFrom(msg.sender, address(this), _sonarTakaAmount * 1e18);
        
        // Update liquidity
        rayverseLiquidity = _rayverseAmount * 1e18;
        sonarTakaLiquidity = _sonarTakaAmount * 1e18;
    }
    
    function addLiquidityForRayverse(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(rayverseLiquidity > 0, "Pool not initialized");
        
        // Check allowance
        require(tokenA.allowance(msg.sender, address(this)) >= amount * 1e18, "Insufficient allowance");
        
        tokenA.safeTransferFrom(msg.sender, address(this), amount * 1e18);
        balances[msg.sender] += amount * 1e18;
        rayverseLiquidity += amount * 1e18;
    }
    
    function addLiquidityForSonarTaka(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(sonarTakaLiquidity > 0, "Pool not initialized");
        
        // Check allowance
        require(tokenB.allowance(msg.sender, address(this)) >= amount * 1e18, "Insufficient allowance");
        
        tokenB.safeTransferFrom(msg.sender, address(this), amount * 1e18);
        balances[msg.sender] += amount * 1e18;
        sonarTakaLiquidity += amount * 1e18;
    }
    
    function removeLiquidityForRayverse(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= amount * 1e18, "Insufficient balance");
        
        tokenA.safeTransfer(msg.sender, amount * 1e18);
        balances[msg.sender] -= amount * 1e18;
        rayverseLiquidity -= amount * 1e18;
    }
    
    function removeLiquidityForSonarTaka(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= amount * 1e18, "Insufficient balance");
        
        tokenB.safeTransfer(msg.sender, amount * 1e18);
        balances[msg.sender] -= amount * 1e18;
        sonarTakaLiquidity -= amount * 1e18;
    }
    
    function swapRayverseToSonarTaka(uint256 amount) external returns (uint256) {
        require(amount > 0, "Amount must be greater than zero");
        require(rayverseLiquidity > 0 && sonarTakaLiquidity > 0, "Pool not initialized");
        
        // Check allowance
        require(tokenA.allowance(msg.sender, address(this)) >= amount * 1e18, "Insufficient allowance");
        
        uint256 amountWei = amount * 1e18;
        uint256 sonarTakaAmount = Math.mulDiv(amountWei, sonarTakaLiquidity, rayverseLiquidity);
        
        // Apply 0.3% fee
        uint256 sonarTakaAmountAfterFees = Math.mulDiv(sonarTakaAmount, 997, 1000);
        
        require(sonarTakaAmountAfterFees > 0, "Insufficient output");
        require(sonarTakaAmountAfterFees <= sonarTakaLiquidity, "Insufficient liquidity");
        
        // Transfer tokens
        tokenA.safeTransferFrom(msg.sender, address(this), amountWei);
        tokenB.safeTransfer(msg.sender, sonarTakaAmountAfterFees);
        
        // Update liquidity
        rayverseLiquidity += amountWei;
        sonarTakaLiquidity -= sonarTakaAmountAfterFees;
        
        return sonarTakaAmountAfterFees;
    }
    
    function swapSonarTakaToRayverse(uint256 amount) external returns (uint256) {
        require(amount > 0, "Amount must be greater than zero");
        require(rayverseLiquidity > 0 && sonarTakaLiquidity > 0, "Pool not initialized");
        
        // Check allowance
        require(tokenB.allowance(msg.sender, address(this)) >= amount * 1e18, "Insufficient allowance");
        
        uint256 amountWei = amount * 1e18;
        uint256 rayverseAmount = Math.mulDiv(amountWei, rayverseLiquidity, sonarTakaLiquidity);
        
        // Apply 0.3% fee
        uint256 rayverseAmountAfterFees = Math.mulDiv(rayverseAmount, 997, 1000);
        
        require(rayverseAmountAfterFees > 0, "Insufficient output");
        require(rayverseAmountAfterFees <= rayverseLiquidity, "Insufficient liquidity");
        
        // Transfer tokens
        tokenB.safeTransferFrom(msg.sender, address(this), amountWei);
        tokenA.safeTransfer(msg.sender, rayverseAmountAfterFees);
        
        // Update liquidity
        sonarTakaLiquidity += amountWei;
        rayverseLiquidity -= rayverseAmountAfterFees;
        
        return rayverseAmountAfterFees;
    }
    
    // Getter functions
    function rayverse() external view returns (address) {
        return address(tokenA);
    }
    
    function sonarTaka() external view returns (address) {
        return address(tokenB);
    }
    
    function checkRayverseLiquidity() external view returns (uint256) {
        return rayverseLiquidity;
    }
    
    function checkSonarTakaLiquidity() external view returns (uint256) {
        return sonarTakaLiquidity;
    }
    
    function checkRayverseBalance(address user) external view returns (uint256) {
        return tokenA.balanceOf(user);
    }
    
    function checkSonarTakaBalance(address user) external view returns (uint256) {
        return tokenB.balanceOf(user);
    }
    
    function checkPriceRayverseToSonarTaka(uint256 amount) external view returns (uint256) {
        require(rayverseLiquidity > 0 && sonarTakaLiquidity > 0, "Liquidity not initialized");
        uint256 amountWei = amount * 1e18;
        return Math.mulDiv(amountWei, sonarTakaLiquidity, rayverseLiquidity);
    }
    
    function checkPriceSonarTakaToRayverse(uint256 amount) external view returns (uint256) {
        require(rayverseLiquidity > 0 && sonarTakaLiquidity > 0, "Liquidity not initialized");
        uint256 amountWei = amount * 1e18;
        return Math.mulDiv(amountWei, rayverseLiquidity, sonarTakaLiquidity);
    }
}

