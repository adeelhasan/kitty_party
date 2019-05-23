Design Patterns Used

Withdrawl Pattern: 

There are three places where value needs to flow out from the contract, and these are made as withdrawl functions to be invoked by the external account. When an account needs to collect the Kitty, it will need to listen for the event Winner and then call.

In Kitty Auction, the account will also need to collect a refund of a bid that is lost, as well as the interest paid by the winning bid. These will need to be collected by these functions:

 the latter function also addresses re-entrancy attacks by setting the balance of the bid to 0 before doing the value transfer

State Machine : there is a KittyStateContract which manages its internal stage.
