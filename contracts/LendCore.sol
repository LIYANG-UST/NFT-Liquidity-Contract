// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @dev 用户抵押NFT 存储其状态 nftinfo  用户=>NFTs
///      用户提供bid单  存储其状态 bidinfo  用户=>Bids
///      每个Bid 对应一个NFT  一个NFT对应多个Bid    NFT=>Bids
///      匹配成功， 由staker触发匹配订单交易 存储成功的/正在进行订单 NFT=>Bid
///      staker提取 NFT  需要还清利息
///      lender提取 NFT  需要满足清算条件 check清算条件  取消订单 cancelOrder
///      利息计算器

contract LendCore {
    address owner;

    IERC20 usd;

    uint256 globalId;

    uint256 bidRewardPerBlock;

    enum Status {
        FREE,
        MATCHED,
        REDEEMED
    }

    struct BidInfo {
        address bider;
        uint256 bidPrice;
        uint256 startBlock;
        uint256 interestRate; // per block
        uint256 timeLength; // in terms of block
    }
    // User address => All his bids
    mapping(address => BidInfo[]) biderInfo;

    struct NFTInfo {
        address tokenAddress;
        uint256 tokenId;
        Status status;
    }
    mapping(bytes32 => NFTInfo) NFTList;
    mapping(address => bytes32[]) userNFTList;

    /// Global Id => NFT ID
    mapping(uint256 => bytes32) nftOrderList;

    mapping(bytes32 => BidInfo[]) matchList;
    mapping(bytes32 => BidInfo) activeMatchList;

    event DepositNFT(address _tokenAddress, uint256 _tokenId, address _owner);
    event NewBid(
        address _bider,
        bytes32 _NFTId,
        uint256 _bidAmount,
        uint256 _interestRate,
        uint256 _timeLength
    );

    constructor(uint256 _bidRewardPerBlock) {
        owner = msg.sender;
        bidRewardPerBlock = _bidRewardPerBlock;
    }

    /// @notice Not allow contract address
    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    /// @notice User deposit NFT into the contract, and wait for bids
    /// @param _tokenAddress: NFT token address
    /// @param _tokenId: NFT token Id
    function depositNFT(address _tokenAddress, uint256 _tokenId)
        public
        notContract
    {
        checkOwnership(_tokenAddress, _tokenId);
        bytes32 NFTID = keccak256(abi.encodePacked(_tokenAddress, _tokenId));

        NFTList[NFTID].tokenAddress = _tokenAddress;
        NFTList[NFTID].tokenId = _tokenId;
        NFTList[NFTID].status = Status.FREE;

        userNFTList[msg.sender].push(NFTID);

        nftOrderList[globalId] = NFTID;
        globalId += 1;
        emit DepositNFT(_tokenAddress, _tokenId, msg.sender);
    }

    /// @notice start a new bid
    /// @param _tokenAddress: NFT token address
    /// @param _tokenId: NFT token Id
    /// @param _bidAmount: the amount of the loan(in USD)
    function newBid(
        address _tokenAddress,
        uint256 _tokenId,
        uint256 _bidAmount,
        uint256 _interestRate,
        uint256 _timeLength
    ) public {
        bytes32 NFTID = keccak256(abi.encodePacked(_tokenAddress, _tokenId));

        BidInfo memory tempBidInfo = BidInfo(
            msg.sender,
            _bidAmount,
            block.number,
            _interestRate,
            _timeLength
        );

        biderInfo[msg.sender].push(tempBidInfo);

        matchList[NFTID].push(tempBidInfo);

        emit NewBid(msg.sender, NFTID, _bidAmount, _interestRate, _timeLength);
    }

    /// @notice Match the order. Notify the depositer when his NFT has new bid.
    ///         He can choose one from all the bids and match the order.
    /// @param _tokenAddress: NFT Token address
    function matchOrder(
        address _tokenAddress,
        uint256 _tokenId,
        uint256 _bidOrder
    ) external notContract {
        checkOwnership(_tokenAddress, _tokenId);
        bytes32 NFTID = keccak256(abi.encodePacked(_tokenAddress, _tokenId));

        NFTList[NFTID].status = Status.MATCHED;
    }

    function lenderRedeem() external {}

    function stakerRedeem(
        address _tokenAddress,
        uint256 _tokenId,
        uint256 _order
    ) external {
        checkInterestPayment();
    }

    /// @notice Check if an address is a contract
    /// @param _addr: sender address to be checked
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    /// @notice Check if the NFT belongs to msg.sender
    /// @param _tokenAddress: NFT contract address
    /// @param _tokenId: tokenId of the NFT
    function checkOwnership(address _tokenAddress, uint256 _tokenId)
        internal
        view
    {
        require(
            msg.sender == IERC721(_tokenAddress).ownerOf(_tokenId),
            "You do not own this NFT"
        );
    }
}
