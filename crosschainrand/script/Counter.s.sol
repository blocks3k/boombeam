// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Counter.sol";
import "../src/SuperRandom.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() external {
        address polyGateway = 0xBF62ef1486468a6bd26Dd669C06db43dEd5B849B;
        address polyGasReceiver = 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6;
        address gGateway = 0xe432150cce91c13a887f7D836923d5597adD8E31;
        address gGasReceiver = 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6;
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        string memory goerliRPC = vm.envString("GOERLI_RPC_URL");
        string memory maticRPC = vm.envString("MATIC_RPC_URL");
        vm.createSelectFork(goerliRPC);
        vm.startBroadcast(deployerPrivateKey);
        SuperRandom gRandom = new SuperRandom(gGateway,gGasReceiver);
        vm.stopBroadcast();
        vm.createSelectFork(maticRPC);
        vm.startBroadcast(deployerPrivateKey);
        SuperRandom pRandom = new SuperRandom(polyGateway,polyGasReceiver);
        vm.stopBroadcast();
    }
}
