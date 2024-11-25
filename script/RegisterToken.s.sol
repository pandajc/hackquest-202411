// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BlindBox} from "../src/BlindBox.sol";
import {BlindBoxCardNFT} from "../src/BlindBoxCardNFT.sol";
import {NFTMarket} from "../src/NFTMarket.sol";

contract RegisterTokenScript is Script {
    function setUp() public {}

    function run(address payable _box, address _nft) public {
        uint256 price = 0.0123 ether;
        registerToken(_box, _nft, price);
    }

    function registerToken(address payable _box, address _token, uint256 _price) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        BlindBox(_box).registerToken(address(_token), _price);
        vm.stopBroadcast();
        console.log("registered nft: ", address(_token));
        console.log("open price: ", _price);
    }
}
