//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Rayverse} from "./Rayverse.sol";
import {SonarTaka} from "./SonarTaka.sol";
contract DEX{
using SafeERC20 for IERC20;
Rayverse public rayverse;
SonarTaka public sonarTaka;
IERC20 tokenA = IERC20(address(rayverse));
IERC20 tokenB = IERC20(address(sonarTaka));
uint256 public rayverseLiqudity;
uint256 public sonarTakaLiquidity;
mapping(address => uint256) public balances;
function addLiquidityForRayverse(uint256 amount) external {
    require(amount > 0, "Amount must be greater than zero");
    tokenA.safeTransferFrom(msg.sender, address(this), amount);
    tokenA.approve(address(this), amount);
    balances[msg.sender] += amount;
    rayverseLiqudity += amount;
}
function addLiquidityForSonarTaka(uint256 amount) external {
    require(amount > 0, "Amount must be greater than zero");
    tokenA.safeTransferFrom(msg.sender, address(this), amount);
    tokenA.approve(address(this), amount);
    balances[msg.sender] += amount;
    rayverseLiqudity += amount;
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

}