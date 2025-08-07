// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DEX} from "src/DEX.sol";
import {Rayverse} from  "../src/Rayverse.sol";
import {SonarTaka} from  "../src/SonarTaka.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();
        
        Rayverse rayverse = new Rayverse();
        console.log("Rayverse deployed at:", address(rayverse));

        SonarTaka sonarTaka = new SonarTaka();
        console.log("SonarTaka deployed at:", address(sonarTaka));

        DEX dex = new DEX(address(rayverse), address(sonarTaka));
        console.log("DEX deployed at:", address(dex));
        
        vm.stopBroadcast();
    }
}
