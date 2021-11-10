# ERC-721 Non-Fungible Token Standard, optional metadata extension (IERC721Metadata.sol)

View Source: [@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol](../@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol)

**↗ Extends: [IERC721](IERC721.md)**
**↘ Derived Contracts: [ERC721](ERC721.md)**

**IERC721Metadata**

See https://eips.ethereum.org/EIPS/eip-721

## Functions

- [name()](#name)
- [symbol()](#symbol)
- [tokenURI(uint256 tokenId)](#tokenuri)

### name

Returns the token collection name.

```js
function name() external view
returns(string)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### symbol

Returns the token collection symbol.

```js
function symbol() external view
returns(string)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### tokenURI

Returns the Uniform Resource Identifier (URI) for `tokenId` token.

```js
function tokenURI(uint256 tokenId) external view
returns(string)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| tokenId | uint256 |  | 

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
