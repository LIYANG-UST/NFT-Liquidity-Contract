# IERC165.sol

View Source: [@openzeppelin/contracts/utils/introspection/IERC165.sol](../@openzeppelin/contracts/utils/introspection/IERC165.sol)

**↘ Derived Contracts: [IERC721](IERC721.md)**

**IERC165**

Interface of the ERC165 standard, as defined in the
 https://eips.ethereum.org/EIPS/eip-165[EIP].
 Implementers can declare support of contract interfaces, which can then be
 queried by others ({ERC165Checker}).
 For an implementation, see {ERC165}.

## Functions

- [supportsInterface(bytes4 interfaceId)](#supportsinterface)

### supportsInterface

Returns true if this contract implements the interface defined by
 `interfaceId`. See the corresponding
 https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
 to learn more about how these ids are created.
 This function call must use less than 30 000 gas.

```js
function supportsInterface(bytes4 interfaceId) external view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| interfaceId | bytes4 |  | 

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
