// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
 contract SonarTaka is ERC20 {
    constructor() ERC20("SonarTaka","STK") {
        _mint(msg.sender, 1000000 * 1e18);
    }
 }