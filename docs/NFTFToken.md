# NFTFToken.sol

View Source: [contracts/NFTFToken.sol](../contracts/NFTFToken.sol)

**↗ Extends: [ERC20](ERC20.md)**

**NFTFToken**

## Contract Members
**Constants & Variables**

```js
address internal owner;
address internal minter;

```

**Events**

```js
event MinterChanged(address  oldMinter, address  newMinter);
```

## Modifiers

- [onlyOwner](#onlyowner)
- [onlyMinter](#onlyminter)

### onlyOwner

```js
modifier onlyOwner() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### onlyMinter

```js
modifier onlyMinter() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [constructor()](#)
- [passMinterRole(address _newMinter)](#passminterrole)
- [mint(address _account, uint256 _amount)](#mint)
- [burn(address _account, uint256 _amount)](#burn)

### 

```js
function () public nonpayable ERC20 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### passMinterRole

```js
function passMinterRole(address _newMinter) external nonpayable onlyOwner 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _newMinter | address |  | 

### mint

```js
function mint(address _account, uint256 _amount) external nonpayable onlyMinter 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _account | address |  | 
| _amount | uint256 |  | 

### burn

```js
function burn(address _account, uint256 _amount) external nonpayable onlyMinter 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _account | address |  | 
| _amount | uint256 |  | 

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
