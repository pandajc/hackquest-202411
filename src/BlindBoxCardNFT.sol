// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./Constants.sol";

error TotalSupplyLimit(uint256 id);

contract BlindBoxCardNFT is ERC1155, ERC1155Pausable, AccessControl, ERC1155Burnable, ERC1155Supply {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public immutable maxCardTokenId;
    uint256 public immutable fragmentCountPerCard;
    uint256 public maxId;

    mapping(uint256 => uint256) public permillageProbability;
    mapping(uint256 => uint256) public totalSupplyLimit;

    constructor(
        address _minter,
        uint256 _maxCardTokenId,
        uint256 _fragmentCountPerCard,
        uint256[] memory _probability,
        uint256[] memory _totalSupplyLimit,
        string memory _baseUri
    ) ERC1155(_baseUri) {
        require(_minter != address(0), "invalid minter");
        require(bytes(_baseUri).length > 0, "invalid baseUri");
        require(_maxCardTokenId > 0 && _maxCardTokenId <= 10, "invalid maxCardTokenId");
        require(_fragmentCountPerCard > 0 && _fragmentCountPerCard < 10, "invalid fragmentCountPerCard");
        maxCardTokenId = _maxCardTokenId;
        fragmentCountPerCard = _fragmentCountPerCard;
        maxId = _maxCardTokenId + _maxCardTokenId * _fragmentCountPerCard;
        require(_probability.length == maxId, "invalid probability array length");
        require(_totalSupplyLimit.length == maxId, "invalid totalSupplyLimit array length");

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, _minter);

        uint256 probabilityTotal = 0;
        for (uint256 i = 0; i < maxId; i++) {
            probabilityTotal += _probability[i];
            permillageProbability[i + 1] = _probability[i];
            totalSupplyLimit[i + 1] = _totalSupplyLimit[i];
        }
        require(probabilityTotal == Constants.PROBABILITY_DECIMAL, "invalid probability sum");
    }

    function getProbability(uint256 _tokenId) public view returns (uint256) {
        return permillageProbability[_tokenId];
    }

    function _checkId(uint256 id) internal view {
        require(id >= 1 && id <= maxId, "invalid tokenId");
    }

    function getFragmentIds(uint256 _tokenId) public view returns (uint256[] memory) {
        require(_tokenId >= 1 && _tokenId <= maxCardTokenId, "invalid card tokenId");
        uint256[] memory ids = new uint256[](fragmentCountPerCard);
        for (uint256 i = 0; i < fragmentCountPerCard; i++) {
            ids[i] = _tokenId * fragmentCountPerCard + (i + 1);
        }
        return ids;
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function _checkTotalSupplyLimit(uint256 id) internal view {
        if (super.totalSupply(id) >= totalSupplyLimit[id]) {
            revert TotalSupplyLimit(id);
        }
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyRole(MINTER_ROLE) {
        _checkId(id);
        _checkTotalSupplyLimit(id);
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        for (uint256 i = 0; i < ids.length; i++) {
            _checkId(ids[i]);
            _checkTotalSupplyLimit(ids[i]);
        }
        _mintBatch(to, ids, amounts, data);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        _checkId(tokenId);
        string memory baseURI = super.uri(tokenId);
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json")) : "";
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Pausable, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
