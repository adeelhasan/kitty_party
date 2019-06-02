# Design Patterns Used

## Withdrawl Pattern: 

There are three places where value needs to flow out from the contract, and these are made as withdrawl functions to be invoked by the external account.

In KittyPartyBase.sol:
```solidity
function withdrawMyWinnings() public notInEmergency{
	if ((participants[msg.sender].cycleNumberWon > 0) && !participants[msg.sender].hasWithdrawnWinnings){
		participants[msg.sender].hasWithdrawnWinnings = true;
		uint amountToTransfer = numberOfParticipants * amountPerParticipant;
		msg.sender.transfer(amountToTransfer);
	}
}
```
[code link]

In KittyPartyAuction.sol

the account will also need to collect a refund of a bid that is lost, as well as the interest paid by the winning bid. These will need to be collected by these functions:

 the latter function also addresses re-entrancy attacks by setting the balance of the bid to 0 before doing the value transfer


## State Machine

There is a ThreeStagesForProgress.sol which manages its internal stage. Instead of having stages which were particular to the Kitty Party context, a more generic classification is used to make reuse feasible.


## Restricting Access

RestrictableToOwner.sol is used
TransferrableRestrictableToOwner



## Object Design




[code link]: https://github.com/adeelhasan/kitty_party/blob/9ec8671be22c3cb9d361644b0c13fb0c9ffe8b7d/contracts/KittyPartyBase.sol#L147-L153
