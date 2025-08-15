// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {DEX} from "./DEX.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

 contract SonarTaka is ERC20 {

    constructor() ERC20("SonarTaka","STK") {
        // transferOwnership(_dex);
    }
     function mint(address user,uint256 amount) external {
            _mint(user, amount);
        }
 }