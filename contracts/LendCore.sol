// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title  Lend Core
/// @notice This is the core contract of lending.
///         Every NFT deposited into the contract and every bid proposed
///         by a bider will have its unique id:
///
///             NFTID = keccak256(abi.encodePacked(tokenAddress, tokenId))
///
///         Every bid will be associated with a certain NFT and a NFT will
///         match several bids:
///
///             mapping(bytes32 NFTID => bytes32[] BidId)
///
///         每个Bid 对应一个NFT  一个NFT对应多个Bid    NFT=>Bids
///         匹配成功， 由staker触发匹配订单交易 存储成功的/正在进行订单 NFT=>Bid
///         staker提取 NFT  需要还清利息
///         lender提取 NFT  需要满足清算条件 check清算条件  取消订单 cancelOrder
///         利息计算器

contract LendCore {
    using SafeERC20 for IERC20;

    address owner;

    IERC20 usd;

    uint256 bidRewardPerBlock;

    enum Status {
        FREE,
        MATCHED,
        REDEEMED,
        LIQUIDATED
    }

    /// @dev BidInfo defination and storage
    struct BidInfo {
        address bider;
        uint256 bidPrice;
        uint256 startBlock;
        uint256 interestPerBlock;
        uint256 timeLength; // in terms of block
        bool isMatched;
    }
    mapping(bytes32 => BidInfo) bidList;

    // User address => All his bid Ids
    mapping(address => bytes32[]) biderInfo;

    /// @dev NFTInfo defination and storage
    struct NFTInfo {
        address tokenAddress;
        uint256 tokenId;
        Status status;
    }
    mapping(bytes32 => NFTInfo) NFTList;

    mapping(address => bytes32[]) userNFTList;

    mapping(bytes32 => bytes32[]) matchList;

    mapping(bytes32 => bytes32) activeMatchList;

    event NFTDeposited(address _tokenAddress, uint256 _tokenId, address _owner);
    event NewBid(
        address _bider,
        bytes32 _NFTId,
        uint256 _bidAmount,
        uint256 _interestRate,
        uint256 _timeLength
    );
    event NFTRedeemed(address _tokenAddress, uint256 _tokenId, address _owner);

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

    /// @notice check the pending interest for a user
    /// @param _NFTID: NFT ID (bytes32)
    function pendingInterest(bytes32 _NFTID) public view returns (uint256) {
        require(
            NFTList[_NFTID].status == Status.MATCHED,
            "your nft is not matched currently"
        );

        BidInfo memory bid = bidList[activeMatchList[_NFTID]];
        require(
            block.number > bid.startBlock,
            "has not reached the startBlock"
        );

        uint256 finalBlock = bid.startBlock + bid.timeLength;
        if (block.number <= finalBlock) {
            uint256 blocks = block.number - bid.startBlock;
            uint256 pending = bid.interestPerBlock * blocks;
            return pending;
        } else {
            uint256 pending = bid.interestPerBlock * bid.timeLength;
            return pending;
        }
    }

    /// @notice Given a NFTID, show the match list
    ///         All bids that call for this NFT
    /// @param _NFTID: NFT ID (bytes32)
    function showMatchList(bytes32 _NFTID)
        public
        view
        returns (BidInfo[] memory)
    {
        uint256 length = matchList[_NFTID].length;
        BidInfo[] memory matchListInfo = new BidInfo[](length);
        for (uint256 i = 0; i < length; i++) {
            matchListInfo[i] = bidList[matchList[_NFTID][i]];
        }
        return matchListInfo;
    }

    /// @notice Check a user's NFT list.
    /// @return NFTInfo[] memory
    function showUserNFTList() public view returns (NFTInfo[] memory) {
        uint256 length = userNFTList[msg.sender].length;
        NFTInfo[] memory _nftInfo = new NFTInfo[](length);
        for (uint256 i = 0; i < length; i++) {
            _nftInfo[i] = (NFTList[userNFTList[msg.sender][i]]);
        }
        return _nftInfo;
    }

    /// @notice User deposit NFT into the contract, and wait for bids
    /// @param _tokenAddress: NFT token address
    /// @param _tokenId: NFT token Id
    function depositNFT(address _tokenAddress, uint256 _tokenId)
        external
        notContract
    {
        checkOwnership(_tokenAddress, _tokenId);
        bytes32 NFTID = keccak256(abi.encodePacked(_tokenAddress, _tokenId));

        NFTInfo memory tempNFTInfo = NFTInfo(
            _tokenAddress,
            _tokenId,
            Status.FREE
        );
        NFTList[NFTID] = tempNFTInfo;

        userNFTList[msg.sender].push(NFTID);

        emit NFTDeposited(_tokenAddress, _tokenId, msg.sender);
    }

    /// @notice start a new bid
    /// @param _NFTID: NFTID = keccak256(abi.encodePacked(_tokenAddress, _tokenId))
    ///                (Frontend) web3.utils.soliditySha3(_tokenAddress, _tokenId)
    /// @param _bidAmount: the amount of the loan(in USD)
    /// @param _interestPerBlock: interest per block
    /// @param _timeLength: how long this loan will last
    function newBid(
        bytes32 _NFTID,
        uint256 _bidAmount,
        uint256 _interestPerBlock,
        uint256 _timeLength
    ) public notContract {
        require(_bidAmount > 0, "bid amount need to be larger than zero");
        require(_interestPerBlock > 0, "should have some interest");
        bytes32 bidId = keccak256(abi.encodePacked(msg.sender, _NFTID));

        BidInfo memory tempBidInfo = BidInfo(
            msg.sender,
            _bidAmount,
            type(uint256).max,
            _interestPerBlock,
            _timeLength,
            false
        );
        bidList[bidId] = tempBidInfo;

        biderInfo[msg.sender].push(bidId);

        matchList[_NFTID].push(bidId);

        usd.safeTransferFrom(msg.sender, address(this), _bidAmount);

        emit NewBid(
            msg.sender,
            _NFTID,
            _bidAmount,
            _interestPerBlock,
            _timeLength
        );
    }

    /// @notice Redeem a bid
    /// @param _bidId: BidId (bytes32)
    function redeemBid(bytes32 _NFTID, bytes32 _bidId) external notContract {
        BidInfo memory bid = bidList[_bidId];
        require(bid.isMatched == false, "can not withdraw a matched bid");
        require(bid.bider == msg.sender, "only the bider can redeem");

        removeBidFromMatch(_NFTID, _bidId);
        delete bidList[_bidId];
    }

    /// @notice Match the order. Notify the depositer when his NFT has new bid.
    ///         He can choose one from all the bids and match the order.
    /// @param _NFTID： bytes32 NFTID
    /// @param _bidOrder: the position of this order in the bid list
    function matchOrder(bytes32 _NFTID, uint256 _bidOrder)
        external
        notContract
    {
        // Update the NFT Info
        NFTInfo storage nft = NFTList[_NFTID];
        checkOwnership(nft.tokenAddress, nft.tokenId);
        nft.status = Status.MATCHED;

        // Update the Bid Info
        bytes32 bidId = matchList[_NFTID][_bidOrder];

        activeMatchList[_NFTID] = bidId;
        bidList[bidId].startBlock = block.number;
        bidList[bidId].isMatched = true;

        usd.safeTransfer(msg.sender, bidList[bidId].bidPrice);

        // Delete all unmatched bids
        withdrawUnmatchedFunds(_NFTID, _bidOrder);
        delete matchList[_NFTID];
    }

    function liquidation(bytes32 _NFTID, uint256 _referencePrice) external {
        NFTInfo storage nft = NFTList[_NFTID];
        require(nft.tokenAddress != address(0), "this NFT does not exist");

        checkOwnership(nft.tokenAddress, nft.tokenId);

        require(
            nft.status == Status.MATCHED,
            "this nft has already been redeemed"
        );

        checkLiquidation(_NFTID, _referencePrice);

        transferNFT(nft.tokenAddress, nft.tokenId, msg.sender);

        delete NFTList[_NFTID];
    }

    /// @notice Redeem a NFT
    /// @param _NFTID: NFT ID
    function redeemNFT(bytes32 _NFTID) external {
        NFTInfo storage nft = NFTList[_NFTID];
        checkOwnership(nft.tokenAddress, nft.tokenId);

        require(
            nft.status != Status.REDEEMED,
            "this nft has already been redeemed"
        );

        if (nft.status == Status.FREE) {
            /// @dev If it is free, the owner can redeem it back
            transferNFT(nft.tokenAddress, nft.tokenId, msg.sender);
        } else if (nft.status == Status.MATCHED) {
            /// @dev If it is matched, you need to pay the interest first
            uint256 interestToPay = pendingInterest(_NFTID);
            usd.safeTransferFrom(msg.sender, address(this), interestToPay);
            transferNFT(nft.tokenAddress, nft.tokenId, msg.sender);
        }

        emit NFTRedeemed(nft.tokenAddress, nft.tokenId, msg.sender);

        delete NFTList[_NFTID];
        delete matchList[_NFTID];
    }

    /// @notice Check if an address is a contract
    /// @param _addr: address to be checked
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

    function withdrawUnmatchedFunds(bytes32 _NFTID, uint256 _matchOrder)
        internal
    {
        for (uint256 i = 0; i < matchList[_NFTID].length; i++) {
            if (i != _matchOrder) {
                usd.safeTransfer(
                    bidList[matchList[_NFTID][i]].bider,
                    bidList[matchList[_NFTID][i]].bidPrice
                );
            } else continue;
        }
    }

    function transferNFT(
        address _tokenAddress,
        uint256 _tokenId,
        address _owner
    ) internal {
        IERC721(_tokenAddress).safeTransferFrom(
            address(this),
            _owner,
            _tokenId
        );
    }

    function removeBidFromMatch(bytes32 _NFTID, bytes32 _bidId) internal {
        uint256 length = matchList[_NFTID].length;

        for (uint256 i = 0; i < length; i++) {
            if (matchList[_NFTID][i] == _bidId) {
                for (uint256 j = 0; j < length - i; j++) {
                    matchList[_NFTID][j] = matchList[_NFTID][j + 1];
                }
                matchList[_NFTID].pop();
            } else continue;
        }
    }

    function checkLiquidation(bytes32 _NFTID, uint256 _referencePrice)
        internal
    {
        uint256 pending = pendingInterest(_NFTID);
        bytes32 bidId = activeMatchList[_NFTID];
        require(
            _referencePrice <= bidList[bidId].bidPrice + pending,
            "not fufill the liuquidation requirements"
        );
    }
}
