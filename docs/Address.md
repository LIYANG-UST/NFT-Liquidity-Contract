# Address.sol

View Source: [@openzeppelin/contracts/utils/Address.sol](../@openzeppelin/contracts/utils/Address.sol)

**Address**

Collection of functions related to the address type

## Functions

- [isContract(address account)](#iscontract)
- [sendValue(address payable recipient, uint256 amount)](#sendvalue)
- [functionCall(address target, bytes data)](#functioncall)
- [functionCall(address target, bytes data, string errorMessage)](#functioncall)
- [functionCallWithValue(address target, bytes data, uint256 value)](#functioncallwithvalue)
- [functionCallWithValue(address target, bytes data, uint256 value, string errorMessage)](#functioncallwithvalue)
- [functionStaticCall(address target, bytes data)](#functionstaticcall)
- [functionStaticCall(address target, bytes data, string errorMessage)](#functionstaticcall)
- [functionDelegateCall(address target, bytes data)](#functiondelegatecall)
- [functionDelegateCall(address target, bytes data, string errorMessage)](#functiondelegatecall)
- [verifyCallResult(bool success, bytes returndata, string errorMessage)](#verifycallresult)

### isContract

Returns true if `account` is a contract.
 [IMPORTANT]
 ====
 It is unsafe to assume that an address for which this function returns
 false is an externally-owned account (EOA) and not a contract.
 Among others, `isContract` will return false for the following
 types of addresses:
  - an externally-owned account
  - a contract in construction
  - an address where a contract will be created
  - an address where a contract lived, but was destroyed
 ====

```js
function isContract(address account) internal view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| account | address |  | 

### sendValue

Replacement for Solidity's `transfer`: sends `amount` wei to
 `recipient`, forwarding all available gas and reverting on errors.
 https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
 of certain opcodes, possibly making contracts go over the 2300 gas limit
 imposed by `transfer`, making them unable to receive funds via
 `transfer`. {sendValue} removes this limitation.
 https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
 IMPORTANT: because control is transferred to `recipient`, care must be
 taken to not create reentrancy vulnerabilities. Consider using
 {ReentrancyGuard} or the
 https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].

```js
function sendValue(address payable recipient, uint256 amount) internal nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| recipient | address payable |  | 
| amount | uint256 |  | 

### functionCall

Performs a Solidity function call using a low level `call`. A
 plain `call` is an unsafe replacement for a function call: use this
 function instead.
 If `target` reverts with a revert reason, it is bubbled up by this
 function (like regular Solidity function calls).
 Returns the raw returned data. To convert to the expected return value,
 use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
 Requirements:
 - `target` must be a contract.
 - calling `target` with `data` must not revert.
 _Available since v3.1._

```js
function functionCall(address target, bytes data) internal nonpayable
returns(bytes)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| target | address |  | 
| data | bytes |  | 

### functionCall

Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
 `errorMessage` as a fallback revert reason when `target` reverts.
 _Available since v3.1._

```js
function functionCall(address target, bytes data, string errorMessage) internal nonpayable
returns(bytes)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| target | address |  | 
| data | bytes |  | 
| errorMessage | string |  | 

### functionCallWithValue

Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
 but also transferring `value` wei to `target`.
 Requirements:
 - the calling contract must have an ETH balance of at least `value`.
 - the called Solidity function must be `payable`.
 _Available since v3.1._

```js
function functionCallWithValue(address target, bytes data, uint256 value) internal nonpayable
returns(bytes)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| target | address |  | 
| data | bytes |  | 
| value | uint256 |  | 

### functionCallWithValue

Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
 with `errorMessage` as a fallback revert reason when `target` reverts.
 _Available since v3.1._

```js
function functionCallWithValue(address target, bytes data, uint256 value, string errorMessage) internal nonpayable
returns(bytes)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| target | address |  | 
| data | bytes |  | 
| value | uint256 |  | 
| errorMessage | string |  | 

### functionStaticCall

Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
 but performing a static call.
 _Available since v3.3._

```js
function functionStaticCall(address target, bytes data) internal view
returns(bytes)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| target | address |  | 
| data | bytes |  | 

### functionStaticCall

Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
 but performing a static call.
 _Available since v3.3._

```js
function functionStaticCall(address target, bytes data, string errorMessage) internal view
returns(bytes)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| target | address |  | 
| data | bytes |  | 
| errorMessage | string |  | 

### functionDelegateCall

Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
 but performing a delegate call.
 _Available since v3.4._

```js
function functionDelegateCall(address target, bytes data) internal nonpayable
returns(bytes)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| target | address |  | 
| data | bytes |  | 

### functionDelegateCall

Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
 but performing a delegate call.
 _Available since v3.4._

```js
function functionDelegateCall(address target, bytes data, string errorMessage) internal nonpayable
returns(bytes)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| target | address |  | 
| data | bytes |  | 
| errorMessage | string |  | 

### verifyCallResult

Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
 revert reason using the provided one.
 _Available since v4.3._

```js
function verifyCallResult(bool success, bytes returndata, string errorMessage) internal pure
returns(bytes)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| success | bool |  | 
| returndata | bytes |  | 
| errorMessage | string |  | 

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
