// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

error TokenIdOrderExists(uint256 tokenId);

contract NFTMarket is ERC1155Holder {
    event Purchase(
        address indexed buyer, address indexed nftAddr, uint256 indexed orderId, uint256 price, uint256 amount
    );
    event List(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed orderId,
        uint256 price,
        uint256 amount,
        uint256 tokenId
    );
    event Revoke(address indexed seller, address indexed nftAddr, uint256 indexed orderId);
    event UpdatePrice(address indexed seller, address indexed nftAddr, uint256 indexed orderId, uint256 newPrice);
    event UpdateAmount(address indexed seller, address indexed nftAddr, uint256 indexed orderId, uint256 newAmount);

    struct Order {
        address token;
        uint256 tokenId;
        address owner;
        uint256 price;
        uint256 amount;
    }

    uint256 private currOrderId;
    mapping(uint256 => Order) public orders;
    mapping(address => mapping(address => mapping(uint256 => uint256))) private ownerTokenIdToOrderId;

    fallback() external payable {}
    receive() external payable {}

    function list(address _nftAddr, uint256 _tokenId, uint256 _price, uint256 _amount) public returns (uint256) {
        IERC1155 nft = IERC1155(_nftAddr);
        require(nft.isApprovedForAll(msg.sender, address(this)), "Need Approval");
        require(_price > 0, "invalid price");
        require(_amount > 0, "invalid amount");
        if (ownerTokenIdToOrderId[_nftAddr][msg.sender][_tokenId] > 0) {
            revert TokenIdOrderExists(_tokenId);
        }
        require(ownerTokenIdToOrderId[_nftAddr][msg.sender][_tokenId] == 0, "same tokenId order exsits");
        nft.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "data");
        uint256 orderId = ++currOrderId;
        Order storage order = orders[orderId];
        order.tokenId = _tokenId;
        order.token = _nftAddr;
        order.owner = msg.sender;
        order.amount = _amount;
        order.price = _price;
        ownerTokenIdToOrderId[_nftAddr][msg.sender][_tokenId] = orderId;
        emit List(msg.sender, _nftAddr, orderId, _price, _amount, _tokenId);
        return orderId;
    }

    function purchase(uint256 _orderId, uint256 _amount) public payable {
        Order storage order = orders[_orderId];
        require(order.amount > 0, "invalid order");
        require(_amount > 0 && _amount <= order.amount, "invalid amount");
        require(order.owner != msg.sender, "cannot purchase own token");
        uint256 totalValue = order.price * _amount;
        require(msg.value >= totalValue, "not enough value");
        IERC1155 nft = IERC1155(order.token);

        // 将NFT转给买家
        nft.safeTransferFrom(address(this), msg.sender, order.tokenId, _amount, "");
        // 将ETH转给卖家
        payable(order.owner).transfer(totalValue);
        // 多余ETH给买家退款
        if (msg.value > totalValue) {
            payable(msg.sender).transfer(msg.value - totalValue);
        }
        order.amount -= _amount;
        emit Purchase(msg.sender, order.token, _orderId, order.price, _amount);
        if (order.amount == 0) {
            delete orders[_orderId];
            delete ownerTokenIdToOrderId[order.token][order.owner][order.tokenId];
        }
    }

    function _checkOrder(Order storage order) private view {
        require(order.amount > 0, "invalid order");
        require(order.owner == msg.sender, "Not Owner");
    }

    function revoke(uint256 _orderId) public {
        Order storage order = orders[_orderId];
        _checkOrder(order);
        IERC1155 nft = IERC1155(order.token);
        uint256 tokenId = order.tokenId;
        require(nft.balanceOf(address(this), tokenId) > 0, "invalid order");
        nft.safeTransferFrom(address(this), msg.sender, tokenId, order.amount, "");
        emit Revoke(msg.sender, order.token, _orderId);
        delete orders[_orderId];
        delete ownerTokenIdToOrderId[order.token][order.owner][tokenId];
    }

    function updatePrice(uint256 _orderId, uint256 _newPrice) public {
        require(_newPrice > 0, "Invalid Price");
        Order storage order = orders[_orderId];
        _checkOrder(order);
        require(order.price != _newPrice, "price not modified");
        uint256 tokenId = order.tokenId;
        address nftAddr = order.token;
        IERC1155 nft = IERC1155(nftAddr);
        require(nft.balanceOf(address(this), tokenId) > 0, "invalid order");
        order.price = _newPrice;
        emit UpdatePrice(msg.sender, nftAddr, _orderId, _newPrice);
    }

    function updateAmount(uint256 _orderId, uint256 _amount) public {
        require(_amount > 0, "invalid amount");
        Order storage order = orders[_orderId];
        _checkOrder(order);
        require(order.amount != _amount, "amount not modified");
        uint256 tokenId = order.tokenId;
        address nftAddr = order.token;
        IERC1155 nft = IERC1155(nftAddr);
        require(nft.balanceOf(address(this), tokenId) > 0, "invalid order");
        if (_amount > order.amount) {
            nft.safeTransferFrom(msg.sender, address(this), tokenId, _amount - order.amount, "");
        } else {
            nft.safeTransferFrom(address(this), msg.sender, tokenId, order.amount - _amount, "");
        }
        order.amount = _amount;
        emit UpdateAmount(msg.sender, nftAddr, _orderId, _amount);
    }

    function get(uint256 _tokenId) public view returns (Order memory) {
        return orders[_tokenId];
    }
}
