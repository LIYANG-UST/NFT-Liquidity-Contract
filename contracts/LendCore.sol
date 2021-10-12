// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract LendCore {
    address owner;

    uint256 globalId;

    struct BidInfo {
        address bider;
        uint256 bidPrice;
        uint256 startBlock;
    }
    mapping(address => BidInfo) biderInfo;

    struct NFTInfo {
        address tokenAddress;
        uint256 tokenId;
    }
    mapping(bytes32 => NFTInfo) nftList;
    mapping(uint256 => bytes32) nftOrderList;

    mapping(bytes32 => BidInfo[]) matchList;

    event DepositNFT(address _tokenAddress, uint256 _tokenId, address _owner);
    event NewBid(address _bider, uint256 _bidAmount, bytes32 _NFTId);

    constructor() {
        owner = msg.sender;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    function depositNFT(address _tokenAddress, uint256 _tokenId)
        public
        notContract
    {
        bytes32 NFTID = keccak256(abi.encodePacked(_tokenAddress, _tokenId));

        nftList[NFTID].tokenAddress = _tokenAddress;
        nftList[NFTID].tokenId = _tokenId;

        nftOrderList[globalId] = NFTID;
        globalId += 1;
        emit DepositNFT(_tokenAddress, _tokenId, msg.sender);
    }

    function newBid(
        address _tokenAddress,
        uint256 _tokenId,
        uint256 _bidAmount
    ) public {
        bytes32 NFTID = keccak256(abi.encodePacked(_tokenAddress, _tokenId));

        BidInfo memory tempBiderInfo = BidInfo(
            msg.sender,
            _bidAmount,
            block.number
        );
        biderInfo[msg.sender] = tempBiderInfo;

        matchList[NFTID].push(tempBiderInfo);

        emit NewBid(msg.sender, _bidAmount, NFTID);
    }

    /**
     * @notice Check if an address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}
