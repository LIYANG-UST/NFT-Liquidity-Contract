// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NFTFToken is ERC20 {
    address owner;
    address minter;

    event MinterChanged(address oldMinter, address newMinter);

    constructor() ERC20("NFTFToken", "NFTF") {
        owner = msg.sender;
        minter = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only the owner can call this functon");
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "only the minter can call this function");
    }

    function passMinterRole(address _newMinter) external onlyOwner {
        minter = _newMinter;
        emit MinterChanged(msg.sender, _newMinter);
    }

    function mint(address _account, uint256 _amount) external onlyMinter {
        _mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) external onlyMinter {
        _burn(_account, _amount);
    }
}
