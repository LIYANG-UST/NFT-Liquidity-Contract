# LendCore.sol

View Source: [contracts/LendCore.sol](../contracts/LendCore.sol)

**LendCore**

## Structs
### BidInfo

```js
struct BidInfo {
 address bider,
 uint256 bidPrice,
 uint256 startBlock
}
```

### NFTInfo

```js
struct NFTInfo {
 address tokenAddress,
 uint256 tokenId
}
```

## Contract Members
**Constants & Variables**

```js
address internal owner;
uint256 internal globalId;
mapping(address => struct LendCore.BidInfo) internal biderInfo;
mapping(bytes32 => struct LendCore.NFTInfo) internal nftList;
mapping(uint256 => bytes32) internal nftOrderList;
mapping(bytes32 => struct LendCore.BidInfo[]) internal matchList;

```

**Events**

```js
event DepositNFT(address  _tokenAddress, uint256  _tokenId, address  _owner);
event NewBid(address  _bider, uint256  _bidAmount, bytes32  _NFTId);
```

## Modifiers

- [notContract](#notcontract)

### notContract

```js
modifier notContract() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [constructor()](#)
- [depositNFT(address _tokenAddress, uint256 _tokenId)](#depositnft)
- [newBid(address _tokenAddress, uint256 _tokenId, uint256 _bidAmount)](#newbid)
- [_isContract(address _addr)](#_iscontract)

### 

```js
function () public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### depositNFT

```js
function depositNFT(address _tokenAddress, uint256 _tokenId) public nonpayable notContract 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _tokenAddress | address |  | 
| _tokenId | uint256 |  | 

### newBid

start a new bid

```js
function newBid(address _tokenAddress, uint256 _tokenId, uint256 _bidAmount) public nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _tokenAddress | address | : the NFT token address | 
| _tokenId | uint256 |  | 
| _bidAmount | uint256 |  | 

### _isContract

Check if an address is a contract

```js
function _isContract(address _addr) internal view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _addr | address |  | 

## Contracts

* [Context](Context.md)
* [ERC20](ERC20.md)
* [IERC165](IERC165.md)
* [IERC20](IERC20.md)
* [IERC20Metadata](IERC20Metadata.md)
* [IERC721](IERC721.md)
* [LendCore](LendCore.md)
* [Migrations](Migrations.md)
* [NFTFToken](NFTFToken.md)
