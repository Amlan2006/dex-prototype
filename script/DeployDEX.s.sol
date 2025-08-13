// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/DEX.sol";
import "../src/Rayverse.sol";
import "../src/SonarTaka.sol";

contract DeployScript is Script {
    function run() external {
        // uint256 pk = vm.envUint("PRIVATE_KEY");
        // address deployer = vm.addr(pk);

        vm.startBroadcast();

        // 1) Deploy tokens
        Rayverse ray = new Rayverse();
         vm.stopBroadcast();
         vm.startBroadcast();
        SonarTaka stk = new SonarTaka();
vm.stopBroadcast();
         
        // 2) Deploy DEX
        vm.startBroadcast();
        DEX dex = new DEX(address(ray), address(stk), address(ray), address(stk));

        // 3) Get initial balance from DEX (this gives deployer tokens)
        dex.getSomeBalance();

        // 4) Approvals for liquidity seeding
        ray.approve(address(dex), type(uint256).max);
        stk.approve(address(dex), type(uint256).max);

        // 5) Initialize liquidity (inputs are in whole units; contract multiplies by 1e18)
        // e.g., seed 100,000 of each side
        dex.initializeLiquidity(100_000, 100_000);

        // console.log("Deployer         :", deployer);
        console.log("Rayverse (RAY)   :", address(ray));
        console.log("SonarTaka (STK)  :", address(stk));
        console.log("DEX              :", address(dex));

        vm.stopBroadcast();
    }
}
