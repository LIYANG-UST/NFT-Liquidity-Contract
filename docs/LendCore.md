# Lend Core (LendCore.sol)

View Source: [contracts/LendCore.sol](../contracts/LendCore.sol)

**↗ Extends: [IERC721Receiver](IERC721Receiver.md)**

**LendCore**

This is the core contract of lending.
         Every NFT deposited into the contract and every bid proposed
         by a bider will have its unique id:
             NFTID = keccak256(abi.encodePacked(tokenAddress, tokenId))
             BIDID = keccak256(abi.encodePacked(biderAddress, tokenAddress))
             (Frontend) web3.utils.soliditySha3(<parameters>)
         Every bid will be associated with a certain NFT and a NFT will
         match several bids:
             NFT => [bid, bid, bid...]
             bid => NFT
             mapping(bytes32 NFTID => bytes32[] BidId)
         匹配成功， 由staker触发匹配订单交易 存储成功的/正在进行订单 NFT=>Bid
         staker提取 NFT  需要还清利息
         lender提取 NFT  需要满足清算条件 check清算条件  取消订单 cancelOrder
         利息计算器

**Enums**
### Status

```js
enum Status {
 NULL,
 FREE,
 MATCHED
}
```

## Structs
### BidInfo

```js
struct BidInfo {
 address bider,
 uint256 bidAmount,
 uint256 startBlock,
 uint256 interestPerBlock,
 uint256 timeLength,
 bool isMatched
}
```

### NFTInfo

```js
struct NFTInfo {
 address owner,
 address tokenAddress,
 uint256 tokenId,
 enum LendCore.Status status
}
```

## Contract Members
**Constants & Variables**

```js
address internal owner;
contract IERC20 internal usd;
uint256 internal bidRewardPerBlock;
uint256 internal feeRate;
uint256 internal globalId;
mapping(bytes32 => struct LendCore.BidInfo) internal bidList;
mapping(address => bytes32[]) internal biderInfo;
mapping(bytes32 => struct LendCore.NFTInfo) internal NFTList;
mapping(address => bytes32[]) internal userNFTList;
mapping(bytes32 => bytes32[]) internal matchList;
mapping(bytes32 => bytes32) internal activeMatchList;
mapping(uint256 => bytes32) internal globalNFTList;

```

**Events**

```js
event NFTDeposited(address  _tokenAddress, uint256  _tokenId, address  _owner);
event NewBid(address  _bider, bytes32  _NFTId, uint256  _bidAmount, uint256  _interestRate, uint256  _timeLength);
event OrderMatched(address  _tokenAddress, uint256  _tokenId, address  _staker, address  _bider);
event FreeNFTRedeemed(address  _tokenAddress, uint256  _tokenId, address  _owner);
event MatchedNFTRedeemed(address  _tokenAddress, uint256  _tokenId, address  _owner);
event Liquidation(address  _tokenAddress, uint256  _tokenId, address  _owner);
event OwnershipTransfer(address  _newOwner);
```

## Modifiers

- [notContract](#notcontract)
- [onlyOwner](#onlyowner)

### notContract

Not allow contract address

```js
modifier notContract() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### onlyOwner

Only the owner can call some functions

```js
modifier onlyOwner() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [constructor(uint256 _bidRewardPerBlock, uint256 _feeRate, address _usd)](#)
- [onERC721Received(address , address , uint256 , bytes )](#onerc721received)
- [pendingInterest(bytes32 _NFTID)](#pendinginterest)
- [showMatchList(bytes32 _NFTID)](#showmatchlist)
- [showUserNFTList()](#showusernftlist)
- [showActiveMatch(bytes32 _NFTID)](#showactivematch)
- [showGlobalList()](#showgloballist)
- [hasRecorded(bytes32 _NFTID)](#hasrecorded)
- [getRecorded(bytes32 _NFTID)](#getrecorded)
- [depositNFT(address _tokenAddress, uint256 _tokenId)](#depositnft)
- [newBid(bytes32 _NFTID, uint256 _bidAmount, uint256 _interestPerBlock, uint256 _timeLength)](#newbid)
- [redeemBid(bytes32 _NFTID, bytes32 _bidId)](#redeembid)
- [matchOrder(bytes32 _NFTID, uint256 _bidOrder)](#matchorder)
- [liquidation(bytes32 _NFTID, uint256 _referencePrice)](#liquidation)
- [redeemNFT(bytes32 _NFTID)](#redeemnft)
- [_isContract(address _addr)](#_iscontract)
- [checkOwnership(address _tokenAddress, uint256 _tokenId)](#checkownership)
- [withdrawUnmatchedFunds(bytes32 _NFTID, uint256 _matchOrder)](#withdrawunmatchedfunds)
- [transferNFT(address _tokenAddress, uint256 _tokenId, address _from, address _to)](#transfernft)
- [removeBidFromMatch(bytes32 _NFTID, bytes32 _bidId)](#removebidfrommatch)
- [checkLiquidation(bytes32 _NFTID, uint256 _referencePrice)](#checkliquidation)
- [ownershipTransfer(address _newOwner)](#ownershiptransfer)
- [setFeeRate(uint256 _newRate)](#setfeerate)

### 

```js
function (uint256 _bidRewardPerBlock, uint256 _feeRate, address _usd) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _bidRewardPerBlock | uint256 |  | 
| _feeRate | uint256 |  | 
| _usd | address |  | 

### onERC721Received

Make this contract can receive ERC721 tokens

```js
function onERC721Received(address , address , uint256 , bytes ) public nonpayable
returns(bytes4)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
|  | address |  | 
|  | address |  | 
|  | uint256 |  | 
|  | bytes |  | 

### pendingInterest

check the pending interest for a user

```js
function pendingInterest(bytes32 _NFTID) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 | : NFT ID (bytes32) | 

### showMatchList

Given a NFTID, show the match list
         All bids that call for this NFT

```js
function showMatchList(bytes32 _NFTID) public view
returns(struct LendCore.BidInfo[])
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 | : NFT ID (bytes32) | 

### showUserNFTList

Check a user's NFT list.

```js
function showUserNFTList() public view
returns(struct LendCore.NFTInfo[])
```

**Returns**

NFTInfo[] memory

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### showActiveMatch

Get the active match result for a certain NFTID

```js
function showActiveMatch(bytes32 _NFTID) public view
returns(struct LendCore.BidInfo)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 | : NFT ID (bytes32) | 

### showGlobalList

Show all the NFTs in the pool,
         including those that has been redeemed/liquidated

```js
function showGlobalList() public view
returns(struct LendCore.NFTInfo[])
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### hasRecorded

```js
function hasRecorded(bytes32 _NFTID) public view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 |  | 

### getRecorded

```js
function getRecorded(bytes32 _NFTID) public view
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 |  | 

### depositNFT

User deposit NFT into the contract, and wait for bids

```js
function depositNFT(address _tokenAddress, uint256 _tokenId) external nonpayable notContract 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _tokenAddress | address | : NFT token address | 
| _tokenId | uint256 | : NFT token Id | 

### newBid

Start a new bid

```js
function newBid(bytes32 _NFTID, uint256 _bidAmount, uint256 _interestPerBlock, uint256 _timeLength) external nonpayable notContract 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 | : NFTID = keccak256(abi.encodePacked(_tokenAddress, _tokenId)) | 
| _bidAmount | uint256 | : the amount of the loan(in USD) | 
| _interestPerBlock | uint256 | : interest per block | 
| _timeLength | uint256 | : how long this loan will last | 

### redeemBid

Redeem a bid

```js
function redeemBid(bytes32 _NFTID, bytes32 _bidId) external nonpayable notContract 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 |  | 
| _bidId | bytes32 | : Bid Id (bytes32) | 

### matchOrder

Match the order. Notify the depositer when his NFT has new bid.
         He can choose one from all the bids and match the order.

```js
function matchOrder(bytes32 _NFTID, uint256 _bidOrder) external nonpayable notContract 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 | ： NFT ID (bytes32) | 
| _bidOrder | uint256 | : the position of this order in the bid list | 

### liquidation

Liquidate a matched order
         The lender will get the NFT itself and the matched order will be cancelled

```js
function liquidation(bytes32 _NFTID, uint256 _referencePrice) external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 | : NFT ID (bytes32) | 
| _referencePrice | uint256 | : Price from oracle | 

### redeemNFT

Redeem a NFT

```js
function redeemNFT(bytes32 _NFTID) external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 | : NFT ID | 

### _isContract

Check if an address is a contract

```js
function _isContract(address _addr) internal view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _addr | address | : address to be checked | 

### checkOwnership

Check if the NFT belongs to msg.sender

```js
function checkOwnership(address _tokenAddress, uint256 _tokenId) internal view
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _tokenAddress | address | : NFT contract address | 
| _tokenId | uint256 | : tokenId of the NFT | 

### withdrawUnmatchedFunds

```js
function withdrawUnmatchedFunds(bytes32 _NFTID, uint256 _matchOrder) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 |  | 
| _matchOrder | uint256 |  | 

### transferNFT

Transfer a NFT Token

```js
function transferNFT(address _tokenAddress, uint256 _tokenId, address _from, address _to) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _tokenAddress | address |  | 
| _tokenId | uint256 |  | 
| _from | address |  | 
| _to | address |  | 

### removeBidFromMatch

```js
function removeBidFromMatch(bytes32 _NFTID, bytes32 _bidId) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 |  | 
| _bidId | bytes32 |  | 

### checkLiquidation

Check whether the liquidation requirements are met

```js
function checkLiquidation(bytes32 _NFTID, uint256 _referencePrice) internal view
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 | : NFT ID (bytes32) | 
| _referencePrice | uint256 | : Price from the oracle | 

### ownershipTransfer

```js
function ownershipTransfer(address _newOwner) external nonpayable onlyOwner 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _newOwner | address |  | 

### setFeeRate

```js
function setFeeRate(uint256 _newRate) external nonpayable onlyOwner 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _newRate | uint256 |  | 

## Contracts

* [Address](Address.md)
* [Context](Context.md)
* [ERC165](ERC165.md)
* [ERC20](ERC20.md)
* [ERC721](ERC721.md)
* [IERC165](IERC165.md)
* [IERC20](IERC20.md)
* [IERC20Metadata](IERC20Metadata.md)
* [IERC721](IERC721.md)
* [IERC721Metadata](IERC721Metadata.md)
* [IERC721Receiver](IERC721Receiver.md)
* [LendCore](LendCore.md)
* [Migrations](Migrations.md)
* [NFTFToken](NFTFToken.md)
* [Ownable](Ownable.md)
* [SafeERC20](SafeERC20.md)
* [Strings](Strings.md)
* [TestNFT](TestNFT.md)
