// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BlindBoxCardNFT} from "../src/BlindBoxCardNFT.sol";
import {BlindBox} from "../src/BlindBox.sol";
import {Helper} from "./Helper.sol";

contract BlindBoxTest is Test, Helper {
    BlindBox box;
    uint256 price = 0.0123 ether;

    function setUp() public {
        vm.startPrank(msg.sender);
        initNFTContract();
        box = new BlindBox();
        nft.grantRole(nft.MINTER_ROLE(), address(box));
        box.registerToken(address(nft), price);
        nft.setApprovalForAll(address(box), true);
    }

    function test_registerToken() public {
        box.registerToken(address(nft), price);
        assertEq(box.tokenToPrice(address(nft)), price);
    }

    function test_registerTokenWithInvalidToken() public {
        vm.expectRevert();
        box.registerToken(address(0), price);
    }

    function test_registerTokenWithInvalidPrice() public {
        vm.expectRevert();
        box.registerToken(address(nft), 0);
    }

    function test_combine() public {
        address account = msg.sender;
        vm.startPrank(account);
        uint256 tokenId = 1;
        uint256[] memory fragIds = nft.getFragmentIds(tokenId);
        uint256 fragMintAmount = 2;
        for (uint256 i = 0; i < fragIds.length; i++) {
            nft.mint(account, fragIds[i], fragMintAmount, "");
        }

        vm.expectEmit(true, true, true, false);
        emit BlindBox.Combined(tokenId, address(nft), account);
        box.combine(address(nft), tokenId);
        assertEq(nft.balanceOf(account, tokenId), 1);
        assertEq(nft.balanceOf(account, fragIds[0]), fragMintAmount - 1);
    }

    function test_revertWhenCombineWithInvalidToken() public {
        vm.startPrank(msg.sender);
        vm.expectRevert();
        box.combine(address(0), 1);
    }

    function test_revertWhenCombineWithInvalidTokenId() public {
        vm.startPrank(msg.sender);
        vm.expectRevert();
        box.combine(address(nft), 9999);
    }

    function test_revertWhenCombineWithoutFragment() public {
        vm.startPrank(msg.sender);
        vm.expectRevert();
        box.combine(address(nft), 1);
    }

    function test_revertWhenOpenBoxWithInvalidToken() public {
        vm.startPrank(msg.sender);
        vm.expectRevert();
        box.openBox{value: 1 ether}(address(0), 1);
    }

    function test_revertWhenOpenBoxWithInvalidCount() public {
        vm.startPrank(msg.sender);
        vm.expectRevert();
        box.openBox{value: 1 ether}(address(nft), 999999);
    }

    function test_revertWhenOpenBoxWithLowerValue() public {
        vm.startPrank(msg.sender);
        vm.expectRevert();
        box.openBox{value: 1 wei}(address(nft), 999999);
    }

    function test_openBox() public {
        vm.startPrank(msg.sender);
        uint256 count = 10;
        vm.expectEmit(true, true, false, false);
        uint256[] memory ids = new uint256[](fragmentCountPerCard);
        emit BlindBox.BoxOpend(address(nft), msg.sender, ids);
        uint256 oldAccountBalance = payable(msg.sender).balance;
        box.openBox{value: oldAccountBalance}(address(nft), count);
        assertEq(payable(address(box)).balance, price * count);
        uint256 newAccountBalance = payable(msg.sender).balance;
        uint256 bal = oldAccountBalance - price * count;
        assertEq(newAccountBalance, bal);
    }
}
