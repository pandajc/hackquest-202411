// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BlindBoxCardNFT} from "../src/BlindBoxCardNFT.sol";
import {NFTMarket} from "../src/NFTMarket.sol";
import {Helper} from "./Helper.sol";

contract NFTMarketTest is Test, Helper {
    NFTMarket market;
    uint256 mintAmount = 10;
    uint256 amount = 5;
    uint256 price = 100;
    uint256 tokenId = 1;
    address nftAddr;
    uint256 orderId;

    function setUp() public {
        initNFTContract();
        nftAddr = address(nft);
        market = new NFTMarket();
        initList();
    }

    function initList() public {
        vm.startPrank(msg.sender);
        nft.mint(msg.sender, tokenId, mintAmount, "");
        nft.setApprovalForAll(address(market), true);
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.List(msg.sender, nftAddr, tokenId, price, amount);
        orderId = market.list(nftAddr, tokenId, price, amount);
        console.log("return orderId: ", orderId);
    }

    function test_list() public view {
        NFTMarket.Order memory o = market.get(orderId);
        assertEq(o.amount, amount);
        assertEq(nft.balanceOf(msg.sender, tokenId), mintAmount - amount);
    }

    function test_revertWhenListWithWrongId() public {
        vm.expectRevert();
        market.list(nftAddr, 999, price, amount);
    }

    function test_revertWhenListWithWrongPrice() public {
        vm.expectRevert();
        market.list(nftAddr, tokenId, 0, amount);
    }

    function test_revertWhenListWithMoreAmount() public {
        vm.expectRevert();
        market.list(nftAddr, tokenId, price, type(uint256).max);
    }

    function test_updatePrice() public {
        vm.startPrank(msg.sender);
        uint256 newPrice = 600;
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.UpdatePrice(msg.sender, nftAddr, tokenId, newPrice);
        market.updatePrice(orderId, newPrice);
        NFTMarket.Order memory o = market.get(orderId);
        assertEq(o.price, newPrice);
    }

    function test_revertWhenUpdateWithWrongId() public {
        vm.expectRevert();
        market.updatePrice(99, price);
    }

    function test_revertWhenUpdateWithWrongPrice() public {
        vm.expectRevert();
        market.updatePrice(orderId, 0);
    }

    function test_revertWhenUpdateWithWrongOwner() public {
        vm.startPrank(address(this));
        vm.expectRevert();
        market.updatePrice(orderId, price);
    }

    function test_revoke() public {
        vm.startPrank(msg.sender);
        vm.expectEmit(true, true, true, false);
        emit NFTMarket.Revoke(msg.sender, nftAddr, tokenId);
        market.revoke(orderId);
        NFTMarket.Order memory o = market.get(orderId);
        assertEq(o.amount, 0);
    }

    function test_revertWhenRevokeWithWrongId() public {
        vm.expectRevert();
        market.revoke(999);
    }

    function test_revertWhenRevokeWithWrongOwner() public {
        vm.startPrank(address(this));
        vm.expectRevert();
        market.revoke(orderId);
    }

    function test_purchase() public {
        uint256 purchaseAmount = 1;
        address bob = _useBobAddr();
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.Purchase(bob, nftAddr, tokenId, price, purchaseAmount);
        market.purchase{value: 10000}(orderId, purchaseAmount);
        NFTMarket.Order memory o = market.get(orderId);
        assertEq(o.amount, amount - purchaseAmount);
        assertEq(nft.balanceOf(bob, tokenId), purchaseAmount);
        vm.stopPrank();
    }

    function _useBobAddr() private returns (address) {
        address bob = vm.addr(2);
        vm.deal(bob, 1 ether);
        vm.startPrank(bob);
        return bob;
    }

    function test_purchaseWhenPurchaseOwnToken() public {
        vm.startPrank(msg.sender);
        vm.expectRevert();
        market.purchase{value: 10000}(999, 1);
        vm.stopPrank();
    }

    function test_purchaseWhenPurchaseWithWrongId() public {
        _useBobAddr();
        vm.expectRevert();
        market.purchase{value: 10000}(999, 1);
        vm.stopPrank();
    }

    function test_purchaseWhenPurchaseWithMoreAmount() public {
        _useBobAddr();
        vm.expectRevert();
        market.purchase{value: 10000}(orderId, amount + 1);
        vm.stopPrank();
    }

    function test_purchaseWhenPurchaseWithoutValue() public {
        _useBobAddr();
        vm.expectRevert();
        market.purchase(orderId, 1);
        vm.stopPrank();
    }

    function test_updateAmountLess() public {
        uint256 newAmount = amount - 1;
        vm.startPrank(msg.sender);
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.UpdateAmount(msg.sender, nftAddr, tokenId, newAmount);
        uint256 ownerOldBalance = nft.balanceOf(msg.sender, tokenId);
        uint256 oldAmount = market.get(orderId).amount;
        market.updateAmount(orderId, newAmount);
        assertEq(market.get(orderId).amount, newAmount);
        assertEq(nft.balanceOf(address(market), tokenId), newAmount);
        assertEq(nft.balanceOf(msg.sender, tokenId), ownerOldBalance + (oldAmount - newAmount));
    }

    function test_updateAmountMore() public {
        uint256 newAmount = amount + 1;
        vm.startPrank(msg.sender);
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.UpdateAmount(msg.sender, nftAddr, tokenId, newAmount);
        uint256 ownerOldBalance = nft.balanceOf(msg.sender, tokenId);
        uint256 oldAmount = market.get(orderId).amount;
        market.updateAmount(orderId, newAmount);
        assertEq(market.get(orderId).amount, newAmount);
        assertEq(nft.balanceOf(address(market), tokenId), newAmount);
        assertEq(nft.balanceOf(msg.sender, tokenId), ownerOldBalance - (newAmount - oldAmount));
    }
}
