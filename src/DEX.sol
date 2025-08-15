// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import{Rayverse} from "./Rayverse.sol";
import{SonarTaka} from "./SonarTaka.sol";

// Fully Corrected DEX contract
contract DEX {
    using SafeERC20 for IERC20;
    
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public rayverseLiquidity;
    uint256 public sonarTakaLiquidity;
    address public feesVaultRayverse;
    address public feesVaultSonarTaka;
    address private owner;
    Rayverse public rayverse;
    SonarTaka public sonarTaka;
    
    mapping(address user => uint256 rayverseamount) public userToRayverseAmount;
    mapping(address user => uint256 sonarTakaAmount) public userToSonarTakaAmount; 
    mapping(address lpProviders => uint256 rayverseamount) public liquidityProvidersRayverse;
    mapping(address lpProviders => uint256 sonarTakaAmount) public liquidityProvidersSonarTaka;
    uint256 public rayVerseFeesAmount;
    uint256 public sonarTakaFeesAmount;
    address[] public liquidityProvidersRAY;
    address[] public liquidityProvidersSTK;
    
    constructor() {
        rayverse = new Rayverse();
        sonarTaka = new SonarTaka();
        tokenA = IERC20(rayverse);
        tokenB = IERC20(sonarTaka);
        owner = msg.sender;
        
        // FIX: Initialize fee vault addresses
        feesVaultRayverse = address(this); // Fees go to the contract itself for now
        feesVaultSonarTaka = address(this);
    }
    
    function getSomeBalance() public payable {
        require(msg.sender != address(0), "Invalid address");
        
        rayverse.mint(msg.sender, 10000 * 1e18);
        userToRayverseAmount[msg.sender] += 10000 * 1e18;
        sonarTaka.mint(msg.sender, 10000 * 1e18);
        userToSonarTakaAmount[msg.sender] += 10000 * 1e18;
    }

    function recieveFeesRayverse() public returns (uint256) {
        uint256 totalLiquidity = rayverseLiquidity;
        require(totalLiquidity > 0, "No liquidity in Rayverse");
        uint256 amount = rayVerseFeesAmount;
        require(amount > 0, "No fees to collect");
        uint256 sharingAmount = Math.mulDiv(amount, LPsharesInPoolRayverse(msg.sender), 100 * 1e18);
        tokenA.safeTransfer(msg.sender, sharingAmount);
        return sharingAmount;
    }

    function recieveFeesSonarTaka() public returns (uint256) {
        uint256 totalLiquidity = sonarTakaLiquidity;
        require(totalLiquidity > 0, "No liquidity in SonarTaka");
        uint256 amount = sonarTakaFeesAmount;
        require(amount > 0, "No fees to collect");
        uint256 sharingAmount = Math.mulDiv(amount, LPsharesInPoolSonarTaka(msg.sender), 100 * 1e18);
        tokenB.safeTransfer(msg.sender, sharingAmount);
        return sharingAmount;
    }
    
    function LPsharesInPoolRayverse(address user) public view returns (uint256) {
        require(user != address(0), "Invalid address");
        uint256 totalRayverseLiquidity = rayverseLiquidity;
        uint256 userRayverseAmount = liquidityProvidersRayverse[user];
        require(totalRayverseLiquidity > 0, "No liquidity in pool");
        require(userRayverseAmount > 0, "No shares in pool");
        uint256 sharePercentage = Math.mulDiv(userRayverseAmount, 100 * 1e18, totalRayverseLiquidity);
        return sharePercentage;
    }
    
    function LPsharesInPoolSonarTaka(address user) public view returns (uint256) {
        require(user != address(0), "Invalid address");
        uint256 totalSonarTakaLiquidity = sonarTakaLiquidity;
        uint256 userSonarTakaAmount = liquidityProvidersSonarTaka[user];
        require(totalSonarTakaLiquidity > 0, "No liquidity in pool");
        require(userSonarTakaAmount > 0, "No shares in pool");
        uint256 sharePercentage = Math.mulDiv(userSonarTakaAmount, 100 * 1e18, totalSonarTakaLiquidity);
        return sharePercentage;
    }

    function initializeLiquidity(uint256 _rayverseAmount, uint256 _sonarTakaAmount) external {
        require(_rayverseAmount > 0 && _sonarTakaAmount > 0, "Amount must be greater than zero");
        require(userToRayverseAmount[msg.sender] >= _rayverseAmount * 1e18, "Insufficient Rayverse balance");
        require(userToSonarTakaAmount[msg.sender] >= _sonarTakaAmount * 1e18, "Insufficient SonarTaka balance");
        
        tokenA.safeTransferFrom(msg.sender, address(this), _rayverseAmount * 1e18);
        tokenB.safeTransferFrom(msg.sender, address(this), _sonarTakaAmount * 1e18);
        
        if(liquidityProvidersRayverse[msg.sender] == 0){
            liquidityProvidersRAY.push(msg.sender);
        }
        if(liquidityProvidersSonarTaka[msg.sender] == 0){
            liquidityProvidersSTK.push(msg.sender);
        }
        
        rayverseLiquidity += _rayverseAmount * 1e18;
        liquidityProvidersRayverse[msg.sender] += _rayverseAmount * 1e18;
        userToRayverseAmount[msg.sender] -= _rayverseAmount * 1e18;
        
        sonarTakaLiquidity += _sonarTakaAmount * 1e18;
        liquidityProvidersSonarTaka[msg.sender] += _sonarTakaAmount * 1e18;
        userToSonarTakaAmount[msg.sender] -= _sonarTakaAmount * 1e18;
    }
    
    function addLiquidityForRayverse(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(userToRayverseAmount[msg.sender] >= amount * 1e18, "Insufficient user balance");
        require(tokenA.balanceOf(msg.sender) >= amount*1e18,"Not enough tokens" );
        
        if(liquidityProvidersRayverse[msg.sender] == 0){
            liquidityProvidersRAY.push(msg.sender);
        }
        
        tokenA.safeTransferFrom(msg.sender, address(this), amount * 1e18);
        rayverseLiquidity += amount * 1e18;
        liquidityProvidersRayverse[msg.sender] += amount * 1e18;
        userToRayverseAmount[msg.sender] -= amount * 1e18;
    }

    function addLiquidityForSonarTaka(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(userToSonarTakaAmount[msg.sender] >= amount * 1e18, "Insufficient user balance");
        
        if(liquidityProvidersSonarTaka[msg.sender] == 0){
            liquidityProvidersSTK.push(msg.sender);
        }
        
        tokenB.safeTransferFrom(msg.sender, address(this), amount * 1e18);
        sonarTakaLiquidity += amount * 1e18;
        liquidityProvidersSonarTaka[msg.sender] += amount * 1e18;
        userToSonarTakaAmount[msg.sender] -= amount * 1e18;
    }

    function removeLiquidityForRayverse(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(liquidityProvidersRayverse[msg.sender] >= amount * 1e18, "Insufficient LP tokens");
        require(rayverseLiquidity >= amount * 1e18, "Insufficient contract liquidity");
        
        tokenA.safeTransfer(msg.sender, amount * 1e18);
        rayverseLiquidity -= amount * 1e18;
        liquidityProvidersRayverse[msg.sender] -= amount * 1e18;
        userToRayverseAmount[msg.sender] += amount * 1e18;
    }

    function removeLiquidityForSonarTaka(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(liquidityProvidersSonarTaka[msg.sender] >= amount * 1e18, "Insufficient LP tokens");
        require(sonarTakaLiquidity >= amount * 1e18, "Insufficient contract liquidity");
        
        tokenB.safeTransfer(msg.sender, amount * 1e18);
        sonarTakaLiquidity -= amount * 1e18;
        liquidityProvidersSonarTaka[msg.sender] -= amount * 1e18;
        userToSonarTakaAmount[msg.sender] += amount * 1e18;
    }
    
    function swapRayverseToSonarTaka(uint256 amount) external returns (uint256) {
        require(amount > 0, "Amount must be greater than zero");
        require(rayverseLiquidity > 0 && sonarTakaLiquidity > 0, "Pool not initialized");
        
        uint256 amountWei = amount * 1e18;
        uint256 sonarTakaAmount = Math.mulDiv(amountWei, sonarTakaLiquidity, rayverseLiquidity);
        
        uint256 sonarTakaAmountAfterFees = Math.mulDiv(sonarTakaAmount, 997, 1000);
        uint256 totalfees = sonarTakaAmount - sonarTakaAmountAfterFees;
        
        require(sonarTakaAmountAfterFees > 0, "Insufficient output");
        require(sonarTakaAmountAfterFees <= sonarTakaLiquidity, "Insufficient liquidity");
        
        tokenA.safeTransferFrom(msg.sender, address(this), amountWei);
        tokenB.safeTransfer(msg.sender, sonarTakaAmountAfterFees);
        
        // Send fees to vault (which is the contract itself for now)
        if(totalfees > 0){
            // Fees stay in the contract since feesVaultSonarTaka = address(this)
            rayVerseFeesAmount += totalfees;
        }
        
        rayverseLiquidity += amountWei;
        sonarTakaLiquidity -= sonarTakaAmountAfterFees;
        
        return sonarTakaAmountAfterFees;
    }
    
    function swapSonarTakaToRayverse(uint256 amount) external returns (uint256) {
        require(amount > 0, "Amount must be greater than zero");
        require(rayverseLiquidity > 0 && sonarTakaLiquidity > 0, "Pool not initialized");
        
        uint256 amountWei = amount * 1e18;
        uint256 rayverseAmount = Math.mulDiv(amountWei, rayverseLiquidity, sonarTakaLiquidity);
        
        uint256 rayverseAmountAfterFees = Math.mulDiv(rayverseAmount, 997, 1000);
        uint256 totalfees = rayverseAmount - rayverseAmountAfterFees;
        
        require(rayverseAmountAfterFees > 0, "Insufficient output");
        require(rayverseAmountAfterFees <= rayverseLiquidity, "Insufficient liquidity");
        
        tokenB.safeTransferFrom(msg.sender, address(this), amountWei);
        tokenA.safeTransfer(msg.sender, rayverseAmountAfterFees);
        
        // Send fees to vault (which is the contract itself for now)
        if(totalfees > 0){
            // Fees stay in the contract since feesVaultRayverse = address(this)
            sonarTakaFeesAmount += totalfees;

        }
        
        sonarTakaLiquidity += amountWei;
        rayverseLiquidity -= rayverseAmountAfterFees;
        
        return rayverseAmountAfterFees;
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