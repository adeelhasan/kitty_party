A Kitty Party is an informal savings scheme, popular in the Indian sub continent, though there are variants in other parts of the world.

A group of people -- usually women -- who are socially acquainted with each other decide to pool a fixed sum of money every month (or a fixed time period which is usually a month) and physically gather in one place. This pool of money or the "kitty" is then picked up by one person each month (or the elected time period.) Its traditional for there to be food, and for the meeting place to be a restaurant, particularly if the group is a well heeled. Hence the name, Kitty Party. There are as many kitty parties as there are participants, and its customary for the winner of that cycle to foot the bill, or to host it at their own home.

Who gets the kitty every month is usually based on some kind of a lottery. This lottery can be at the first Kitty Party, or it can be at each meeting. There are also variants where the participants can place a blind bid on the kitty, and the winning bid is then split amongst the participants who in fact had foregone the kitty amount for that month. The bids can be place directly, or the money that would be available if the kitty is won can also be used.

This scheme is informal in that if one person cannot show up, then they send the money along with a neighbour, or they drop it off the  next day.

----------------

Design Decisions

There is a base contract which imposes an overall structure, and descendant classes which implement key abstract functions. This is also called the Template Design Pattern for class design.

KittyPartyBase has the overall structure for the functionality.

-- KittySequential
   -- KittyPartyLotteryBase
        --KittyPartyLotteryOraclize
        --KittyPartyLotteryUpgradable
-- KittyPartyAuction




Design Patterns Used

Withdrawl Pattern: in the contract KittyPartyAuction, losing bids are returned to their originators. The balance that needs to be returned is kept in the contract. This internal balance is assigned to 0 before the value is transferred back.

State Machine : there is a KittyStateContract which manages its internal stage.

Thought Processes for Common Attacks
- control of the functions that distribute value is limited to the owner, via the modifiers
- 

Aside from the withdrawl patter, 


-Use of ENS
-- Use of IPFS? could be with the kitty partry directory concept
-- use of vyper, can it be use with solidity code
-- use of library for SafeMath

testnet addresses
ropsten:

testing instructions
making a video
