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
    address public feesVaultRayverse;
    address public feesVaultSonarTaka;
    
    // mapping(address => uint256) public balances;
    mapping(address user => uint256 rayverseamount) public userToRayverseAmount;
    mapping(address user => uint256 sonarTakaAmount) public userToSonarTakaAmount; 
    // mapping(address => uint256) public liquidityRayverse;
    // mapping(address => uint256) public liquiditySonarTaka;
    mapping(address lpProviders => uint256 rayverseamount) public liquidityProvidersRayverse;
    mapping(address lpProviders => uint256 sonarTakaAmount) public liquidityProvidersSonarTaka;
    address[] liquidityProvidersRAY;
    address[] liquidityProvidersSTK;
    
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        tokenA.safeTransferFrom(msg.sender, address(this),1000000*1e18);
        tokenA.approve(address(this), type(uint256).max);
        tokenB.safeTransferFrom(msg.sender, address(this),1000000*1e18);
        tokenB.approve(address(this), type(uint256).max);
    }
        function recieveFeesRayverse() public returns (uint256) {
        // This function is a placeholder for receiving fees from the DEX
        uint256 totalLiquidity = rayverseLiquidity;
        require(totalLiquidity > 0, "No liquidity in Rayverse");
        uint256 amount = tokenA.balanceOf(feesVaultRayverse);
        uint256 sharingAmount = Math.mulDiv(amount,LPsharesInPoolRayverse(msg.sender),1e18);
        tokenA.safeTransfer(msg.sender, sharingAmount);
        return sharingAmount;
    }

    function recieveFeesSonarTaka() public returns (uint256) {
        // This function is a placeholder for receiving fees from the DEX
        uint256 totalLiquidity = sonarTakaLiquidity;
        require(totalLiquidity > 0, "No liquidity in SonarTaka");
        uint256 amount = tokenB.balanceOf(feesVaultSonarTaka);
        uint256 sharingAmount = Math.mulDiv(amount,LPsharesInPoolSonarTaka(msg.sender),1e18);
        tokenB.safeTransfer(msg.sender, sharingAmount);
        return sharingAmount;
        
        
    }
    function LPsharesInPoolRayverse(address user) public view returns (uint256) {
        require(msg.sender != address(0), "Invalid address");
        uint256 totalRayverseLiquidity = rayverseLiquidity;
        uint256 userRayverseAmount = liquidityProvidersRayverse[user];
        require(totalRayverseLiquidity > 0, "No liquidity in pool");
        require(userRayverseAmount > 0, "No shares in pool");
        // 100*1e18 = 1e20
        uint256 sharePercentage = Math.mulDiv(userRayverseAmount, 100*1e18, totalRayverseLiquidity);
        return sharePercentage;
        // Do something with sharePercentage

    }
    function LPsharesInPoolSonarTaka(address user) public view returns (uint256) {
        require(msg.sender != address(0), "Invalid address");
        uint256 totalSonarTakaLiquidity = sonarTakaLiquidity;
        uint256 userSonarTakaAmount = liquidityProvidersSonarTaka[user];
        require(totalSonarTakaLiquidity > 0, "No liquidity in pool");
        require(userSonarTakaAmount > 0, "No shares in pool");
        // 100*1e18 = 1e20
        uint256 sharePercentage = Math.mulDiv(userSonarTakaAmount, 100*1e18, totalSonarTakaLiquidity);
        return sharePercentage;
        // Do something with sharePercentage

    }


    function getSomeBalance() public{
        require(msg.sender != address(0), "Invalid address");
        tokenA.safeTransferFrom(address(this), msg.sender, 10000 * 1e18);
        userToRayverseAmount[msg.sender] += 10000 * 1e18;
        tokenB.safeTransferFrom(address(this), msg.sender, 10000 * 1e18);
        userToSonarTakaAmount[msg.sender] += 10000 * 1e18;
    }


    // Initialize liquidity for the DEX
    
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
        if(liquidityProvidersRayverse[msg.sender] == 0){
            liquidityProvidersRAY.push(msg.sender);
        }
        rayverseLiquidity += _rayverseAmount * 1e18;
        liquidityProvidersRayverse[msg.sender] += _rayverseAmount * 1e18;
        userToRayverseAmount[msg.sender] -= _rayverseAmount * 1e18;
        if(liquidityProvidersSonarTaka[msg.sender] == 0){
            liquidityProvidersSTK.push(msg.sender);
        }
        sonarTakaLiquidity += _sonarTakaAmount * 1e18;
        liquidityProvidersSonarTaka[msg.sender] += _sonarTakaAmount * 1e18;
        userToSonarTakaAmount[msg.sender] -= _sonarTakaAmount * 1e18;

    }
    
    function addLiquidityForRayverse(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(rayverseLiquidity > 0, "Pool not initialized");
        
        // Check allowance
        require(tokenA.allowance(msg.sender, address(this)) >= amount * 1e18, "Insufficient allowance");
        
        tokenA.safeTransferFrom(msg.sender, address(this), amount * 1e18);
        // balances[msg.sender] += amount * 1e18;
        rayverseLiquidity += amount * 1e18;
        liquidityProvidersRayverse[msg.sender] += amount * 1e18;
        userToRayverseAmount[msg.sender] -= amount * 1e18;

    }
    
    function addLiquidityForSonarTaka(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(sonarTakaLiquidity > 0, "Pool not initialized");
        
        // Check allowance
        require(tokenB.allowance(msg.sender, address(this)) >= amount * 1e18, "Insufficient allowance");
        
        tokenB.safeTransferFrom(msg.sender, address(this), amount * 1e18);
        // balances[msg.sender] += amount * 1e18;
        sonarTakaLiquidity += amount * 1e18;
        liquidityProvidersSonarTaka[msg.sender] += amount * 1e18;
        userToSonarTakaAmount[msg.sender] -= amount * 1e18;
    }
    
    function removeLiquidityForRayverse(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        // require(balances[msg.sender] >= amount * 1e18, "Insufficient balance");
        
        tokenA.safeTransfer(msg.sender, amount * 1e18);
        // balances[msg.sender] -= amount * 1e18;
        rayverseLiquidity -= amount * 1e18;
        liquidityProvidersRayverse[msg.sender] -= amount * 1e18;
        userToRayverseAmount[msg.sender] += amount * 1e18;
    }
    
    function removeLiquidityForSonarTaka(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        // require(balances[msg.sender] >= amount * 1e18, "Insufficient balance");
        
        tokenB.safeTransfer(msg.sender, amount * 1e18);
        // balances[msg.sender] -= amount * 1e18;
        sonarTakaLiquidity -= amount * 1e18;
        liquidityProvidersSonarTaka[msg.sender] -= amount * 1e18;
        userToSonarTakaAmount[msg.sender] += amount * 1e18;
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
        uint256 totalfees = sonarTakaAmount - sonarTakaAmountAfterFees;
        
        require(sonarTakaAmountAfterFees > 0, "Insufficient output");
        require(sonarTakaAmountAfterFees <= sonarTakaLiquidity, "Insufficient liquidity");
        //Transfer fees to the vault
        if(totalfees > 0){
            tokenB.safeTransfer(feesVaultSonarTaka, totalfees);
        }
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

        //Transfer fees to vault
        uint256 totalfees = rayverseAmount - rayverseAmountAfterFees;
        if(totalfees > 0){
            tokenA.safeTransfer(feesVaultRayverse, totalfees);
        }
        
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

