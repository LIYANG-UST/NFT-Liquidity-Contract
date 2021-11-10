# ERC721 token receiver interface (IERC721Receiver.sol)

View Source: [@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol](../@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol)

**↘ Derived Contracts: [LendCore](LendCore.md)**

**IERC721Receiver**

Interface for any contract that wants to support safeTransfers
 from ERC721 asset contracts.

## Functions

- [onERC721Received(address operator, address from, uint256 tokenId, bytes data)](#onerc721received)

### onERC721Received

Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
 by `operator` from `from`, this function is called.
 It must return its Solidity selector to confirm the token transfer.
 If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
 The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.

```js
function onERC721Received(address operator, address from, uint256 tokenId, bytes data) external nonpayable
returns(bytes4)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| operator | address |  | 
| from | address |  | 
| tokenId | uint256 |  | 
| data | bytes |  | 

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
