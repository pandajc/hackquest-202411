// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BlindBox} from "../src/BlindBox.sol";
import {BlindBoxCardNFT} from "../src/BlindBoxCardNFT.sol";
import {NFTMarket} from "../src/NFTMarket.sol";

contract BlindBoxCardNFTScript is Script {
    BlindBoxCardNFT nft;
    uint256 public maxCardTokenId;
    uint256 public fragmentCountPerCard;
    uint256[] public probabilityArr;
    uint256[] public totalSupplyLimitArr;
    string baseUri = "ipfs://QmVT2QDLGXpnJqTsWsjJEZuyFWifNvXD42QBubPp3JnWnZ/";

    function setUp() public {}

    function run(address _minter) public {
        deployBlindBoxCardNFT(_minter);
    }

    function deployBlindBoxCardNFT(address _minter) public returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        maxCardTokenId = 4;
        fragmentCountPerCard = 4;
        probabilityArr = [0, 0, 0, 0, 10, 30, 30, 30, 50, 50, 100, 100, 60, 60, 90, 90, 75, 75, 75, 75];
        totalSupplyLimitArr =
            [100, 1000, 1000, 1000, 1e4, 1e4, 1e4, 1e4, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6];
        nft = new BlindBoxCardNFT(
            _minter, maxCardTokenId, fragmentCountPerCard, probabilityArr, totalSupplyLimitArr, baseUri
        );
        console.log("nft: ", address(nft));
        vm.stopBroadcast();
        return address(nft);
    }
}
