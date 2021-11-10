# Strings.sol

View Source: [@openzeppelin/contracts/utils/Strings.sol](../@openzeppelin/contracts/utils/Strings.sol)

**Strings**

String operations.

## Contract Members
**Constants & Variables**

```js
bytes16 private constant _HEX_SYMBOLS;

```

## Functions

- [toString(uint256 value)](#tostring)
- [toHexString(uint256 value)](#tohexstring)
- [toHexString(uint256 value, uint256 length)](#tohexstring)

### toString

Converts a `uint256` to its ASCII `string` decimal representation.

```js
function toString(uint256 value) internal pure
returns(string)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| value | uint256 |  | 

### toHexString

Converts a `uint256` to its ASCII `string` hexadecimal representation.

```js
function toHexString(uint256 value) internal pure
returns(string)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| value | uint256 |  | 

### toHexString

Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.

```js
function toHexString(uint256 value, uint256 length) internal pure
returns(string)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| value | uint256 |  | 
| length | uint256 |  | 

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
