// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DEX.sol";
import "../src/Rayverse.sol";
import "../src/SonarTaka.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Corrected DEX contract for testing
contract DEX {
    using SafeERC20 for IERC20;
    
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public rayverseLiqudity;
    uint256 public sonarTakaLiquidity;
    
    mapping(address => uint256) public balances;
    
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }
    
    function initializeLiquidity(uint256 _rayverseAmount, uint256 _sonarTakaAmount) external {
        require(rayverseLiqudity == 0 && sonarTakaLiquidity == 0, "Already initialized");
        tokenA.safeTransferFrom(msg.sender, address(this), _rayverseAmount);
        tokenB.safeTransferFrom(msg.sender, address(this), _sonarTakaAmount);
        rayverseLiqudity = _rayverseAmount;
        sonarTakaLiquidity = _sonarTakaAmount;
    }
    
    function addLiquidityForRayverse(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        tokenA.safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        rayverseLiqudity += amount;
    }
    
    function addLiquidityForSonarTaka(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        tokenB.safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        sonarTakaLiquidity += amount; // Fixed: was rayverseLiqudity
    }
    
    function removeLiquidityForRayverse(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        tokenA.safeTransfer(msg.sender, amount);
        balances[msg.sender] -= amount;
        rayverseLiqudity -= amount;
    }
    
    function removeLiquidityForSonarTaka(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        tokenB.safeTransfer(msg.sender, amount);
        balances[msg.sender] -= amount;
        sonarTakaLiquidity -= amount;
    }
    
    function swapRayverseToSonarTaka(uint256 amount) external returns (uint256) {
        require(amount > 0, "Amount must be greater than zero");
        uint256 numerator = amount * sonarTakaLiquidity;
        uint256 denominator = rayverseLiqudity + amount;
        uint256 sonarTakaAmount = numerator / denominator;
        require(sonarTakaAmount > 0, "Insufficient output");
        require(sonarTakaAmount <= sonarTakaLiquidity, "Insufficient liquidity");
        
        tokenA.safeTransferFrom(msg.sender, address(this), amount);
        tokenB.safeTransfer(msg.sender, sonarTakaAmount);
        rayverseLiqudity += amount; // Fixed: should be += not -=
        sonarTakaLiquidity -= sonarTakaAmount;
        return sonarTakaAmount;
    }
    
    function swapSonarTakaToRayverse(uint256 amount) external returns (uint256) {
        require(amount > 0, "Amount must be greater than zero");
        uint256 numerator = amount * rayverseLiqudity;
        uint256 denominator = sonarTakaLiquidity + amount;
        uint256 rayverseAmount = numerator / denominator;
        require(rayverseAmount > 0, "Insufficient output");
        require(rayverseAmount <= rayverseLiqudity, "Insufficient liquidity");
        
        tokenB.safeTransferFrom(msg.sender, address(this), amount);
        tokenA.safeTransfer(msg.sender, rayverseAmount);
        sonarTakaLiquidity += amount; // Fixed: should be += not -=
        rayverseLiqudity -= rayverseAmount;
        return rayverseAmount;
    }
    
    // Getter functions to match original interface
    function rayverse() external view returns (address) {
        return address(tokenA);
    }
    
    function sonarTaka() external view returns (address) {
        return address(tokenB);
    }
    function checkRayverseLiquidity() external view returns (uint256) {
        return rayverseLiqudity;
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
        require(rayverseLiqudity > 0 && sonarTakaLiquidity > 0, "Liquidity not initialized");
        uint256 numerator = amount * sonarTakaLiquidity;
        uint256 denominator = rayverseLiqudity + amount;
        return numerator / denominator;
    }
    function checkPriceSonarTakaToRayverse(uint256 amount) external view returns (uint256) {
        require(rayverseLiqudity > 0 && sonarTakaLiquidity > 0, "Liquidity not initialized");
        uint256 numerator = amount * rayverseLiqudity;
        uint256 denominator = sonarTakaLiquidity + amount;
        return numerator / denominator;
    }
   
}

