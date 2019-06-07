# Kitty Party

A Kitty Party is an informal savings scheme in which participants pool money each month, and a rotating winner gets that aggregated sum. There are as many iterations as participants, and the primary benefit is to be able to access a lump sum amount. There are variations on how the claimant is decided each cycle.  

- more information on kitty parties is in [user stories](USER_STORIES.md)

The primary goal of this project is to model this process, keeping best practices and Consensys final project requirements in mind.

----------------

## Overview of Design

- [design patterns used](DESIGN_PATTERN_DECISIONS.md)
- [avoiding common attachs](AVOIDING_COMMON_ATTACKS.md)

## Installation

Aside from truffle, the only noteworthy item is that to test oraclize, we need the Ethereum Bridge to be installed. More details below in the testing section.

## Use of a Library
- [SafeAraryLib.sol](helpers/SafeArrayLib.sol)

A very basic library that checks array bounds, linked with [ExternalUintArrayStorage.sol](contracts/helpers/ExternalUintArrayStorage.sol).

## Use of a Circuit Breaker

- [CircuitBreaker.sol](helpers/CircuitBreaker.sol) has modifiers
  ```solidity
    modifier notInEmergency(){require(circuitBreakerState == CircuitBreakerState.NoEmergency,"no emergency"); _;}
    modifier inEmergency(){require(circuitBreakerState != CircuitBreakerState.NoEmergency, "not in emergency"); _;}
    modifier inRedAlert(){require(circuitBreakerState == CircuitBreakerState.RedAlert, "in red alert"); _;}
  ``` 
- [KittyPartyBase.sol](contracts/KittyPartyBase.sol) descends from CircuitBreaker, and uses the modifiers

## Stretch Goal - Upgradable Contract

The lottery for a kitty party needs some form of randomization, and the goal was to be able to upgrade the randomization part of a deployed contract. This then meant that the storage needed to be separated out, and passed to a new randomizer, whose requirement is to implement [IRandomizeRangeToArray.sol](contracts/helpers/randomizers/IRandomizeRangeToArray.sol). It also meant that there was need for a uniform interface to be able to call the randomization that was currently installed.

```solidity
/// @dev abstract function implementation, that makes the randomizer fill out the results
function doInitialLottery() internal {
    IRandomizeRangeToArray randomizer = IRandomizeRangeToArray(upgradableRandomizerAddress);
    randomizer.randomize(numberOfParticipants, externalStorageAddress);
}
```

There are two implementations of [IRandomizeRangeToArray.sol](contracts/helpers/randomizers/IRandomizeRangeToArray.sol):
- [BlockRandomizer.sol](contracts/helpers/randomizers/BlockRandomizer.sol)
- [OraclizeRandomizer.sol](contracts/helpers/randomizers/OraclizeRandomizer.sol)

## Stretch Goal - Use of Oraclize

In determining a random order of winners, a Wolfram Alpha query is used through Oraclize. This is wrapped in the contract [RandomIndicesOraclizeBase.sol](contracts/helpers/randomizers/RandomIndicesOraclizeBase.sol), which will produce a list of n integers within the range of 0 to y. 

## Stretch Goal - Use of ENS

[sequential.kittyparty.test] is registered on ropsten, please visit with Metamask in a ropsten account.

This currently points to the deployed KittyPartySequential.sol contract, and is utilized in the frontend code:

```javascript
//when on ropsten, can use ENS for contract address
var myContractAddress = "";
var myContractAbi = [..];
web3.eth.ens.getAddress('sequential.kittyparty.test').then((address)=>{
  window.myContract = new window.web3.eth.Contract (myContractAbi,address);
  refreshContractInfo();
});
```

## Testing

```
truffle test
```

The only noteworthy item is that to test oraclize, we need the Ethereum Bridge to be installed

- [README.md](oraclizeTest/README.md) for [KittyPartyLotteryOraclize.sol](contracts/KittyPartyLotteryOraclize.sol)

## Testnet Address

- ropsten: [https://ropsten.etherscan.io/address/0xaab4a8e3a7091523d9a230033843715afb98b4ad](https://ropsten.etherscan.io/address/0xaab4a8e3a7091523d9a230033843715afb98b4ad)



## Front End

Deployed :
- https://adeelhasan.github.io/kitty_party/ 
- this is connected to a KittyPartySequential contract 
- have a ropsten account with at least 1 gWei
- click "Contribute to this Cycle"
- the metamask confirmation should come up
- state will get updated to reflect that the participant has contriuted for current cycle


## Presenatation
[https://vimeo.com/340220008](https://vimeo.com/340220008)
[PowerPoint used in the video](kitty_party.pptx)

---------


[sequential.kittyparty.test]:  https://manager.ens.domains/name/sequential.kittyparty.test
