// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BlindBoxCardNFT.sol";
import "./Constants.sol";

contract BlindBox is Ownable {
    event TokenRegistered(address indexed token);
    event Combined(uint256 indexed tokenId, address indexed token, address indexed owner);
    event BoxOpend(address indexed token, address indexed owner, uint256[] tokenIds);

    mapping(address => uint256) public tokenToPrice;

    constructor() Ownable(msg.sender) {}

    fallback() external payable {}
    receive() external payable {}

    function registerToken(address _token, uint256 _price) external onlyOwner {
        require(_price > 0, "invalid price");
        require(BlindBoxCardNFT(_token).maxId() > 0, "invalid token");
        tokenToPrice[_token] = _price;
    }

    function claim(uint256 _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

    function openBox(address _token, uint256 _count) external payable {
        require(_count > 0 && _count <= 10, "invalid count");
        uint256 price = tokenToPrice[_token];
        require(price > 0, "invalid token");
        uint256 amount = price * _count;
        require(msg.value >= amount, "not enough value");
        payable(this).transfer(amount);
        if (msg.value > amount) {
            payable(msg.sender).transfer(msg.value - amount);
        }
        BlindBoxCardNFT nft = BlindBoxCardNFT(_token);
        uint256[] memory nums = _batchRandomNumPseudo(_count);
        uint256[] memory tokenIds = new uint256[](nums.length);
        uint256[] memory amounts = new uint256[](nums.length);
        for (uint256 i = 0; i < nums.length; i++) {
            tokenIds[i] = _selectTokenId(nft, nums[i]);
            amounts[i] = 1;
        }
        nft.mintBatch(msg.sender, tokenIds, amounts, "");
        emit BoxOpend(_token, msg.sender, tokenIds);
    }

    function _selectTokenId(BlindBoxCardNFT nft, uint256 _num) private view returns (uint256) {
        uint256 v = 0;
        for (uint256 j = 1; j <= nft.maxId(); j++) {
            v += nft.getProbability(j);
            if (v >= _num) {
                return j;
            }
        }
        return nft.maxId();
    }

    function combine(address _token, uint256 _tokenId) external {
        require(tokenToPrice[_token] > 0, "invalid token");
        BlindBoxCardNFT nft = BlindBoxCardNFT(_token);
        uint256[] memory ids = nft.getFragmentIds(_tokenId);
        require(ids.length > 0, "invalid card tokenId");
        uint256[] memory values = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            values[i] = 1;
        }
        nft.burnBatch(msg.sender, ids, values);
        nft.mint(msg.sender, _tokenId, 1, "");
        emit Combined(_tokenId, _token, msg.sender);
    }

    function _batchRandomNumPseudo(uint256 _count) private view returns (uint256[] memory) {
        uint256[] memory nums = new uint256[](_count);
        for (uint256 i = 0; i < _count; i++) {
            nums[i] = _pseudoRandom(Constants.PROBABILITY_DECIMAL, i) + 1;
        }
        return nums;
    }

    function _pseudoRandom(uint256 number, uint256 _salt) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.number, block.prevrandao, msg.sender, _salt)))
            % number;
    }
}
