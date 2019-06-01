A Kitty Party is an informal savings scheme, popular in the Indian sub continent, though there are variants in other parts of the world.

A group of people who are socially acquainted with each other decide to pool a fixed sum of money every month (or a fixed time period which is usually a month) and physically gather in one place. This pool of money or the "kitty" is then picked up by one person each month. Its traditional for there to be food, and for the meeting place to be a restaurant, particularly if the group is well heeled. Hence the name, Kitty Party. There are as many kitty parties as there are participants, and its customary for the winner of that cycle to foot the bill, or to host it at their own home. The benefit is to be able to save up for a larger payout, and in some communities its a very relevant way to finance a larger purchase.

Who gets the kitty every month is usually based on some kind of a lottery. This lottery can be at the first party, or it can be at each meeting. There are also variants where the participants can place a bid on the kitty, and the winning bid is then split amongst the participants who in fact had foregone the kitty amount for that month. The bids can be placed directly, or the money that would be available if the kitty is won can also be used.

This scheme is informal in that if one person cannot show up, then they send the money along with a neighbour, or they drop it off the  next day.

User Stories

- someone announces a kitty for a certain amount, and word spreads
- whoever wants to join, gets in touch with the organizer
- if there is space, the organizer says they are in
- the participants have an initial meeting, and everyone brings the designated amount
- if someone couldnt make the meeting, they would have given the amount to the organizer separately
- at the first meeting, there is a random draw -- names are written on paper chits and someone (usually a child) will pick these out
- 

----------------

Design Decisions

There is a base contract which imposes an overall structure, and descendant classes which implement key abstract functions. This is also called the Template Design Pattern for class design, and in this project the nameing convention is to have the templated functions be prefaced by "do" eg, doInitialLottery

- KittyPartyBase 
  - KittySequential
  - KittyPartyLotteryBase
    - KittyPartyLotteryOraclize
    - KittyPartyLotteryUpgradable
  - KittyPartyAuction

<embed an image or thumbnail>
For a UML diagram of this structure, please see :
sol2uml

-- Use of ENS
-- Use of IPFS? could be with the kitty partry directory concept
-- use of vyper, can it be use with solidity code

testnet addresses
ropsten:

testing instructions
making a video


---------

npm install truffle_hardware_wallet
npm install 

setup your process level environment variables

---------

Running the Frontend Application
