# Design Patterns Used

## Withdrawl Pattern: 

There are a couple of places where value needs to flow out from the contract, and these are made as withdrawl functions to be invoked by the external account.

In [KittyPartyBase.sol](contracts/KittyPartyBase.sol) :
```solidity
function withdrawMyWinnings() public notInEmergency {
	require((participants[msg.sender].cycleNumberWon > 0) && !participants[msg.sender].hasWithdrawnWinnings, "nothing to withdraw");
	require((numberOfParticipants * amountPerParticipant)/amountPerParticipant == numberOfParticipants, "overflow failure");

	uint amountToTransfer = numberOfParticipants * amountPerParticipant;
	participants[msg.sender].hasWithdrawnWinnings = true; //reset balance flag to address reentrance
	msg.sender.transfer(amountToTransfer);
}
```
[code link]

In [KittyPartyAuction.sol](contracts/KittyPartyAuction.sol) 

the account will also need to collect a refund of a bid that is lost, as well as the interest paid by the winning bid. These will need to be collected by these functions:

```solidity
function withdrawMyInterest() public {
	uint amount = bidRefundWithdrawls[msg.sender];
	bidRefundWithdrawls[msg.sender] = 0;
	msg.sender.transfer(amount);
}
```
[code link2]


## State Machine

There is a [ProgressInThreeStages.sol](contracts/helpers/ProgressInThreeStages.sol) which manages its internal states. Instead of having stages which were particular to the Kitty Party context, a more generic classification is used to make reuse feasible:

```solidity
    enum Stages {NotStarted, Started, Finished}
```


## Restricting Access

[RestrictableToOwner.sol](contracts/helpers/RestrictableToOwner.sol) is used as a base contract to provide basic modifiers to control access.

I decided not to make this base have a means to transfer ownership, intend to add a descendant along the lines of TransferrableRestrictableToOwner in the future.



## Object Design




[code link]: https://github.com/adeelhasan/kitty_party/blob/9ec8671be22c3cb9d361644b0c13fb0c9ffe8b7d/contracts/KittyPartyBase.sol#L147-L153
[code link2]: https://github.com/adeelhasan/kitty_party/blob/master/contracts/KittyPartyAuction.sol#L71-75
