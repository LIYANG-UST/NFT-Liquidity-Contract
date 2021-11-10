# Context.sol

View Source: [@openzeppelin/contracts/utils/Context.sol](../@openzeppelin/contracts/utils/Context.sol)

**↘ Derived Contracts: [ERC20](ERC20.md), [ERC721](ERC721.md), [Ownable](Ownable.md)**

**Context**

Provides information about the current execution context, including the
 sender of the transaction and its data. While these are generally available
 via msg.sender and msg.data, they should not be accessed in such a direct
 manner, since when dealing with meta-transactions the account sending and
 paying for execution may not be the actual sender (as far as an application
 is concerned).
 This contract is only required for intermediate, library-like contracts.

## Functions

- [_msgSender()](#_msgsender)
- [_msgData()](#_msgdata)

### _msgSender

```js
function _msgSender() internal view
returns(address)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### _msgData

```js
function _msgData() internal view
returns(bytes)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

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
