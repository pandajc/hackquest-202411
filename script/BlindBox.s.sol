// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BlindBox} from "../src/BlindBox.sol";
import {BlindBoxCardNFT} from "../src/BlindBoxCardNFT.sol";
import {NFTMarket} from "../src/NFTMarket.sol";

contract BlindBoxScript is Script {
    function setUp() public {}

    function run() public {
        deployBlindBoxAndMarket();
    }

    function deployBlindBoxAndMarket() public returns (address payable) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        BlindBox box = new BlindBox();
        NFTMarket market = new NFTMarket();
        console.log("box: ", address(box));
        console.log("market: ", address(market));
        vm.stopBroadcast();
        return payable(address(box));
    }
}
