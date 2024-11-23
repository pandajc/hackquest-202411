// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BlindBoxCardNFT, TotalSupplyLimit} from "../src/BlindBoxCardNFT.sol";
import {Helper} from "./Helper.sol";

contract BlindBoxCardNFTTest is Test, Helper {
    function setUp() public {
        initNFTContract();
    }

    function test_mint() public {
        uint256 id = 1;
        nft.mint(msg.sender, id, 1, "");
        assertEq(1, nft.balanceOf(msg.sender, id), "balance after minting not correct");
    }

    function test_uri() public view {
        string memory uri = nft.uri(1);
        console.log("uri is ", uri);
        assertEq(uri, "ipfs://abc/1.json");
    }

    function test_getFragmentIds() public view {
        uint256[] memory ids = nft.getFragmentIds(1);
        uint256[] memory trueIds = new uint256[](fragmentCountPerCard);
        trueIds[0] = 5;
        trueIds[1] = 6;
        trueIds[2] = 7;
        trueIds[3] = 8;
        assertEq(ids, trueIds);
    }

    function test_revertWhenMintReachLimit() public {
        address sender = msg.sender;
        uint256 id = 1;
        nft.mint(sender, id, nft.totalSupplyLimit(id), "");
        // ignore error param
        vm.expectPartialRevert(TotalSupplyLimit.selector);
        nft.mint(sender, id, 1, "");
    }

    function test_revertWhenMintWithWrongTokenId() public {
        vm.expectRevert();
        nft.mint(msg.sender, type(uint256).max, 1, "");
    }

    function test_mintBatch() public {
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1;
        amounts[1] = 1;
        nft.mintBatch(msg.sender, ids, amounts, "");
        assertEq(1, nft.balanceOf(msg.sender, 1), "balance after minting not correct");
    }

    function test_revertWhenMintBatchReachLimit() public {
        address sender = msg.sender;
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1;
        amounts[1] = nft.totalSupplyLimit(2);
        nft.mintBatch(sender, ids, amounts, "");
        // ignore error param
        vm.expectPartialRevert(TotalSupplyLimit.selector);
        nft.mintBatch(sender, ids, amounts, "");
    }

    function test_revertWhenMintBatchWithWrongTokenId() public {
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = type(uint256).max;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1;
        amounts[1] = 1;
        vm.expectRevert();
        nft.mintBatch(msg.sender, ids, amounts, "");
    }
}
