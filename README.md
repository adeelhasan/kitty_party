### Kitty Party

A Kitty Party is an informal savings scheme in which participants pool money each month, and a rotating winner gets that aggregated sum. There are as many iterations as participants, and the primary benefit is to be able to access a lump sum amount. There are variations on how the claimant is decided each cycle.  

- more information on kitty parties is in [user stories](USER_STORIES.md)

The primary goal of this project is to model this process, keeping best practices and Consensys final project requirements in mind.

----------------

## Overview of Design

There is a base contract which imposes an overall structure, and descendant classes which implement key abstract functions. This is also called the Template Design Pattern for class design, and in this project the naming convention is to have the templated functions be prefaced by "do" eg, doGetWinnerIndex

- KittyPartyBase 
  - KittySequential
    - KittyPartyLotteryBase
      - KittyPartyLotteryOraclize
      - KittyPartyLotteryUpgradable
  - KittyPartyAuction

<embed an image or thumbnail>
For a UML diagram of this structure, please see :
sol2uml

## Installation

npm install truffle_hardware_wallet
npm install dotenv

setup your process level environment variables

## Use of a Library

A very basic library that checks array bounds was created. This is then used in the contract that stores a uint array.


------------ Stretch Goals ------------

## Upgradable Contract

The lottery for a kitty party needs some form of randomization, and the goal was to be able to upgrade the randomization part of a deployed contract. This then meant that the storage needed to be separated out, and passed to a new randomization. It also meant that there was need for a uniform interface to be able to call the randomization that was currently installed.

<snippet of the upgradabale kitty party>

## Use of Oraclize

In determining a random order of winners, a Wolfram Alpha query is used through Oraclize.


## Testing


## Front End

- please visit 
- this is connected to a KittyPartySequential contract
- have a ropsten account with at least 1 gWei
- add the account as a participant
- the metamask confirmation should come up
- state will get updated to reflect so


## Testnet Addresses / User of ENS

ropsten: sequential.kittyparty.test


The domain sequential.kittyparty.test was registered to point to the deployment on ropsten, this is currently used in the frontend demo for the system.

(ipfs hash for the ABI code)


## Video Link
making a video


---------

Running the Frontend Application
https://www.kingoftheether.com/contract-safety-checklist.html