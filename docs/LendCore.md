# LendCore.sol

View Source: [contracts/LendCore.sol](../contracts/LendCore.sol)

**LendCore**

用户抵押NFT 存储其状态 nftinfo  用户=>NFTs
      用户提供bid单  存储其状态 bidinfo  用户=>Bids
      每个Bid 对应一个NFT  一个NFT对应多个Bid    NFT=>Bids
      匹配成功， 由staker触发匹配订单交易 存储成功的/正在进行订单 NFT=>Bid
      staker提取 NFT  需要还清利息
      lender提取 NFT  需要满足清算条件 check清算条件  取消订单 cancelOrder
      利息计算器

**Enums**
### Status

```js
enum Status {
 FREE,
 MATCHED,
 REDEEMED
}
```

## Structs
### BidInfo

```js
struct BidInfo {
 address bider,
 uint256 bidPrice,
 uint256 lastInterestBlock,
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
uint256 internal globalId;
uint256 internal bidRewardPerBlock;
mapping(bytes32 => struct LendCore.BidInfo) internal bidList;
mapping(address => bytes32[]) internal biderInfo;
mapping(bytes32 => struct LendCore.NFTInfo) internal NFTList;
mapping(address => bytes32[]) internal userNFTList;
mapping(uint256 => bytes32) internal nftOrderList;
mapping(bytes32 => struct LendCore.BidInfo[]) internal matchList;
mapping(bytes32 => struct LendCore.BidInfo) internal activeMatchList;

```

**Events**

```js
event DepositNFT(address  _tokenAddress, uint256  _tokenId, address  _owner);
event NewBid(address  _bider, bytes32  _NFTId, uint256  _bidAmount, uint256  _interestRate, uint256  _timeLength);
```

## Modifiers

- [notContract](#notcontract)

### notContract

Not allow contract address

```js
modifier notContract() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [constructor(uint256 _bidRewardPerBlock)](#)
- [pendingInterest(bytes32 _NFTID)](#pendinginterest)
- [showMatchList(bytes32 _NFTID)](#showmatchlist)
- [showUserNFTList()](#showusernftlist)
- [depositNFT(address _tokenAddress, uint256 _tokenId)](#depositnft)
- [newBid(bytes32 _NFTID, uint256 _bidAmount, uint256 _interestPerBlock, uint256 _timeLength)](#newbid)
- [redeemBid(uint256 _bidOrder)](#redeembid)
- [matchOrder(bytes32 _NFTID, uint256 _bidOrder)](#matchorder)
- [lenderRedeem()](#lenderredeem)
- [redeemNFT(bytes32 _NFTID, uint256 _order)](#redeemnft)
- [_isContract(address _addr)](#_iscontract)
- [checkOwnership(address _tokenAddress, uint256 _tokenId)](#checkownership)
- [withdrawUnmatchedFunds(bytes32 _NFTID, uint256 _matchOrder)](#withdrawunmatchedfunds)

### 

```js
function (uint256 _bidRewardPerBlock) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _bidRewardPerBlock | uint256 |  | 

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

start a new bid

```js
function newBid(bytes32 _NFTID, uint256 _bidAmount, uint256 _interestPerBlock, uint256 _timeLength) public nonpayable notContract 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 | : NFTID = keccak256(abi.encodePacked(_tokenAddress, _tokenId))                 (Frontend) web3.utils.soliditySha3(_tokenAddress, _tokenId) | 
| _bidAmount | uint256 | : the amount of the loan(in USD) | 
| _interestPerBlock | uint256 | : interest per block | 
| _timeLength | uint256 | : how long this loan will last | 

### redeemBid

Redeem a bid

```js
function redeemBid(uint256 _bidOrder) external nonpayable notContract 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _bidOrder | uint256 |  | 

### matchOrder

Match the order. Notify the depositer when his NFT has new bid.
         He can choose one from all the bids and match the order.

```js
function matchOrder(bytes32 _NFTID, uint256 _bidOrder) external nonpayable notContract 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 | ： bytes32 NFTID | 
| _bidOrder | uint256 | : the position of this order in the bid list | 

### lenderRedeem

```js
function lenderRedeem() external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### redeemNFT

Redeem a NFT

```js
function redeemNFT(bytes32 _NFTID, uint256 _order) external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _NFTID | bytes32 | : bytes32 NFT ID | 
| _order | uint256 |  | 

### _isContract

Check if an address is a contract

```js
function _isContract(address _addr) internal view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _addr | address | : sender address to be checked | 

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

## Contracts

* [Address](Address.md)
* [Context](Context.md)
* [ERC20](ERC20.md)
* [IERC165](IERC165.md)
* [IERC20](IERC20.md)
* [IERC20Metadata](IERC20Metadata.md)
* [IERC721](IERC721.md)
* [LendCore](LendCore.md)
* [Migrations](Migrations.md)
* [NFTFToken](NFTFToken.md)
* [SafeERC20](SafeERC20.md)
