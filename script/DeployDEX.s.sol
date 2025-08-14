// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Script} from "forge-std/Script.sol";
import {DEX} from "../src/DEX.sol";
import {Rayverse} from "../src/Rayverse.sol";
import {SonarTaka} from "../src/SonarTaka.sol";
import {console2} from "forge-std/console2.sol";
contract DeployDEXScript is Script {
    function run() external returns (address) {
        vm.startBroadcast();
        // Deploy the DEX contract
        DEX dex = new DEX();
        console2.log("DEX deployed at:", address(dex));
        
        // Deploy the Rayverse token
        
        console2.log("Rayverse deployed at:", address(dex.rayverse()));

        
        // Deploy the SonarTaka token
        
        console2.log("SonarTaka deployed at:", address(dex.sonarTaka()));
        
        // Set the DEX in both tokens
        vm.stopBroadcast();
        
        return address(dex);
    }
}