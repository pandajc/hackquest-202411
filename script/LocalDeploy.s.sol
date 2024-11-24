// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BlindBoxScript} from "./BlindBox.s.sol";
import {BlindBoxCardNFTScript} from "./BlindBoxCardNFT.s.sol";
import {RegisterTokenScript} from "./RegisterToken.s.sol";

contract LocalDeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 price = 1 gwei;
        BlindBoxScript blindBoxScript = new BlindBoxScript();
        BlindBoxCardNFTScript blindBoxCardNFTScript = new BlindBoxCardNFTScript();
        RegisterTokenScript registerTokenScript = new RegisterTokenScript();
        address payable boxAddr = blindBoxScript.deployBlindBoxAndMarket();
        address nftAddr = blindBoxCardNFTScript.deployBlindBoxCardNFT(boxAddr);
        registerTokenScript.registerToken(boxAddr, nftAddr, price);
    }
}
