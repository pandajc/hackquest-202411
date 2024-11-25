// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {BlindBoxCardNFT} from "../src/BlindBoxCardNFT.sol";

abstract contract Helper {
    BlindBoxCardNFT public nft;
    uint256 public maxCardTokenId;
    uint256 public fragmentCountPerCard;
    uint256[] public probabilityArr;
    uint256[] public totalSupplyLimitArr;
    string baseUri = "ipfs://abc/";

    function initNFTContract() public {
        maxCardTokenId = 4;
        fragmentCountPerCard = 4;
        probabilityArr = [0, 0, 0, 0, 10, 30, 30, 30, 50, 50, 100, 100, 60, 60, 90, 90, 75, 75, 75, 75];
        totalSupplyLimitArr =
            [100, 1000, 1000, 1000, 1e4, 1e4, 1e4, 1e4, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6];
        nft = new BlindBoxCardNFT(
            msg.sender, maxCardTokenId, fragmentCountPerCard, probabilityArr, totalSupplyLimitArr, baseUri
        );
    }
}
