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
///             BIDID = keccak256(abi.encodePacked(biderAddress, tokenAddress))
///             (Frontend) web3.utils.soliditySha3(<parameters>)
///
///         Every bid will be associated with a certain NFT and a NFT will
///         match several bids:
///             NFT => [bid, bid, bid...]
///             bid => NFT
///             mapping(bytes32 NFTID => bytes32[] BidId)
///
///         匹配成功， 由staker触发匹配订单交易 存储成功的/正在进行订单 NFT=>Bid
///         staker提取 NFT  需要还清利息
///         lender提取 NFT  需要满足清算条件 check清算条件  取消订单 cancelOrder
///         利息计算器

contract LendCore {
    using SafeERC20 for IERC20;

    address owner;

    IERC20 usd;

    uint256 bidRewardPerBlock;

    uint256 feeRate;

    enum Status {
        NULL,
        FREE,
        MATCHED
    }

    /// @dev BidInfo defination and storage
    struct BidInfo {
        address bider;
        uint256 bidAmount;
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
    event OrderMatched(
        address _tokenAddress,
        uint256 _tokenId,
        address _staker,
        address _bider
    );
    event FreeNFTRedeemed(
        address _tokenAddress,
        uint256 _tokenId,
        address _owner
    );
    event MatchedNFTRedeemed(
        address _tokenAddress,
        uint256 _tokenId,
        address _owner
    );
    event Liquidation(address _tokenAddress, uint256 _tokenId, address _owner);
    event OwnershipTransfer(address _newOwner);

    constructor(uint256 _bidRewardPerBlock, uint256 _feeRate) {
        owner = msg.sender;
        bidRewardPerBlock = _bidRewardPerBlock;
        feeRate = _feeRate;
    }

    ///  ******************************  ///
    ///          Modifier Part           ///
    ///  ******************************  ///

    /// @notice Not allow contract address
    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    /// @notice Only the owner can call some functions
    modifier onlyOwner() {
        require(msg.sender == owner, "only the owner can call this function");
        _;
    }

    ///  ******************************  ///
    ///        View Function Part        ///
    ///  ******************************  ///

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

    ///  ******************************  ///
    ///        Main Function Part        ///
    ///  ******************************  ///

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

    /// @notice Start a new bid
    /// @param _NFTID: NFTID = keccak256(abi.encodePacked(_tokenAddress, _tokenId))
    /// @param _bidAmount: the amount of the loan(in USD)
    /// @param _interestPerBlock: interest per block
    /// @param _timeLength: how long this loan will last
    function newBid(
        bytes32 _NFTID,
        uint256 _bidAmount,
        uint256 _interestPerBlock,
        uint256 _timeLength
    ) external notContract {
        require(_bidAmount > 0, "bid amount need to be larger than zero");
        require(_interestPerBlock > 0, "should have some interest");
        require(_timeLength > 0, "should have a period");

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

        // deposit some assets into this contract
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
    /// @param _bidId: Bid Id (bytes32)
    function redeemBid(bytes32 _NFTID, bytes32 _bidId) external notContract {
        BidInfo memory bid = bidList[_bidId];
        require(bid.isMatched == false, "can not withdraw a matched bid");
        require(bid.bider == msg.sender, "only the bider can redeem");

        removeBidFromMatch(_NFTID, _bidId);
        delete bidList[_bidId];
    }

    /// @notice Match the order. Notify the depositer when his NFT has new bid.
    ///         He can choose one from all the bids and match the order.
    /// @param _NFTID： NFT ID (bytes32)
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

        // The staker get his loan
        usd.safeTransfer(msg.sender, bidList[bidId].bidAmount);

        // Delete all unmatched bids
        // withdrawUnmatchedFunds(_NFTID, _bidOrder);
        // delete matchList[_NFTID];
        emit OrderMatched(
            nft.tokenAddress,
            nft.tokenId,
            msg.sender,
            bidList[bidId].bider
        );
    }

    /// @notice Liquidate a matched order
    ///         The lender will get the NFT itself and the matched order will be cancelled
    /// @param _NFTID: NFT ID (bytes32)
    /// @param _referencePrice: Price from oracle
    function liquidation(bytes32 _NFTID, uint256 _referencePrice) external {
        NFTInfo storage nft = NFTList[_NFTID];
        require(nft.tokenAddress != address(0), "this NFT does not exist");

        checkOwnership(nft.tokenAddress, nft.tokenId);

        require(
            nft.status == Status.MATCHED,
            "this nft is not matched currently"
        );

        checkLiquidation(_NFTID, _referencePrice);

        transferNFT(nft.tokenAddress, nft.tokenId, msg.sender);
        emit Liquidation(nft.tokenAddress, nft.tokenId, msg.sender);

        delete NFTList[_NFTID];
    }

    /// @notice Redeem a NFT
    /// @param _NFTID: NFT ID
    function redeemNFT(bytes32 _NFTID) external {
        NFTInfo storage nft = NFTList[_NFTID];

        require(nft.tokenAddress != address(0), "this nft does not exist");

        checkOwnership(nft.tokenAddress, nft.tokenId);

        if (nft.status == Status.FREE) {
            /// @dev If it is free, the owner can redeem it back
            transferNFT(nft.tokenAddress, nft.tokenId, msg.sender);
            emit FreeNFTRedeemed(nft.tokenAddress, nft.tokenId, msg.sender);
        } else if (nft.status == Status.MATCHED) {
            /// @dev If it is matched, you need to pay the interest first
            uint256 interestToPay = pendingInterest(_NFTID);
            uint256 loanAmount = bidList[activeMatchList[_NFTID]].bidAmount;
            address lender = bidList[activeMatchList[_NFTID]].bider;
            usd.safeTransferFrom(
                msg.sender,
                lender,
                interestToPay + loanAmount
            );
            transferNFT(nft.tokenAddress, nft.tokenId, msg.sender);
            emit MatchedNFTRedeemed(nft.tokenAddress, nft.tokenId, msg.sender);
        }

        delete NFTList[_NFTID];
        delete matchList[_NFTID];
    }

    ///  ******************************  ///
    ///      Internal Function Part      ///
    ///  ******************************  ///

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
                    bidList[matchList[_NFTID][i]].bidAmount
                );
            } else continue;
        }
    }

    /// @notice Transfer a NFT Token
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

    /// @notice Check whether the liquidation requirements are met
    /// @param _NFTID: NFT ID (bytes32)
    /// @param _referencePrice: Price from the oracle
    function checkLiquidation(bytes32 _NFTID, uint256 _referencePrice)
        internal
        view
    {
        uint256 pending = pendingInterest(_NFTID);
        bytes32 bidId = activeMatchList[_NFTID];
        require(
            _referencePrice <= bidList[bidId].bidAmount + pending,
            "not fufill the liuquidation requirements"
        );
    }

    ///  ******************************  ///
    ///        Owner Function Part       ///
    ///  ******************************  ///

    function ownershipTransfer(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "empty address");
        owner = _newOwner;
        emit OwnershipTransfer(_newOwner);
    }

    function setFeeRate(uint256 _newRate) external onlyOwner {
        require(_newRate >= 0 && _newRate < 100, "fee rate outside 0~100");
        feeRate = _newRate;
    }
}
