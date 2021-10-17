// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestNFT is ERC721, Ownable {
    uint256 public _nextId;

    constructor() ERC721("Test", "TES") {}

    function mint(address _to) public onlyOwner {
        uint256 tokenId = _nextId++;
        _mint(_to, tokenId);
    }
}
