// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "../modules/libs/Counters.sol";

import "../modules/ERC721URIStorage.sol";

contract NFTDefault is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;

    constructor(address marketplaceAddress, string memory name, string memory symbol) ERC721(name, symbol) {
        contractAddress = marketplaceAddress;
    }

    function createToken(string memory tokenURI) public returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }
}
