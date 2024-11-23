// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {BlindBoxCardNFT} from "../src/BlindBoxCardNFT.sol";

abstract contract Helper {
    BlindBoxCardNFT public nft;
    uint256 public maxCardTokenId;
    uint256 public fragmentCountPerCard;
    uint256[] public probabilityArr;
    uint256[] public totalSupplyLimitArr;
    string baseUri;

    function initNFTContract() public {
        maxCardTokenId = 4;
        fragmentCountPerCard = 4;
        probabilityArr = [0, 0, 0, 0, 25, 25, 25, 25, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75];
        totalSupplyLimitArr = [5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10];
        baseUri = "ipfs://abc/";
        nft = new BlindBoxCardNFT(
            msg.sender, maxCardTokenId, fragmentCountPerCard, probabilityArr, totalSupplyLimitArr, baseUri
        );
    }
}
