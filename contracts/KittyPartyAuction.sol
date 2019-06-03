pragma solidity >=0.4.21 <0.6.0;

import "./KittyPartyBase.sol";

/**
  In this variant, each cycle of a Kitty has an auction amongst the participants who have not
  won in a cycle before.

  though bids are optional, at least one bid is required for there to be a result, unless at the last cycle
 */
contract KittyPartyAuction is KittyPartyBase
{
    struct Bid {
      uint amount;
      bool winningBid;
      bool exists;
    }

    mapping(address=>uint) public bidRefundWithdrawls;
    mapping(address=>Bid) public bids;
    uint public numberOfBidders;
    uint constant MAX_BID_VALUE = MAX_CONTRIBUTION;

    modifier hasBid() {
      require(bids[msg.sender].exists,"bid exists");
      _;
    }

    modifier hasNotBidAsYet() {
        require(!bids[msg.sender].exists,"bid does not exist");
        _;
    }

    modifier nonZeroBid(){
        require(msg.value > 0, "bid has to be non zero");
        _;
    }

    /// @dev log that a bid was made
    event BidReceived(address indexed bidder);

    constructor (uint _amount) KittyPartyBase(_amount) public {}

    /// @dev receive a bid, has to be sent in by an existing participant
    function receiveBid()
      public
      notInEmergency
      isAParticipant
      hasNotBidAsYet
      nonZeroBid
      hasNotWonACycle
      payable
    {
        require(numberOfParticipants!=currentCycleNumber, "should not be the last cycle");
        require(msg.value <= MAX_BID_VALUE, "has to be less than the max bid value");
        bids[msg.sender] = Bid(msg.value,false,true);
        numberOfBidders++;
        emit BidReceived(msg.sender);
    }

    /// @dev utility function to get the sender's bid
    function getMyBid() public view returns (uint, bool, bool) {
        Bid memory bid = bids[msg.sender];
        if (bid.exists)
            return (bid.amount, bid.winningBid, bid.exists);
        else
            return (0,false,false);
    }

    /// @dev after a cycle is finished, a participant can claim their share of the winner's bid + failed bid value
    function withdrawMyInterest() public {
        uint amount = bidRefundWithdrawls[msg.sender];
        bidRefundWithdrawls[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    /// @dev this is called by base class when in an emergency, the user can withdraw a bid
    function doWithdrawMyRefund() internal {
        if (bids[msg.sender].exists){
            bids[msg.sender].amount = 0;    //the internal balance is set to 0
            msg.sender.transfer(bids[msg.sender].amount);
        }
    }

    /// @dev implementation of abstract to get the winner for this cycle
    function doGetWinner() internal returns (address) {
        //if this is the last cycle, so no bidders here, just return the remaining participant who has not won as yet
        if ((numberOfParticipants - currentCycleNumber) < 1) {
          for (uint i = 0; i<numberOfParticipants; i++) {
            if (participants[participant_addresses[i]].cycleNumberWon==0)
              return participant_addresses[i];
          }
        }

        uint highestBidIndex = 0;   // the index will be passed back to the super class as the winner
        uint highestBidAmount = 0;  // the winning amount could be logged
        for (uint i = 0; i<numberOfParticipants; i++) {
            if (bids[participant_addresses[i]].exists && bids[participant_addresses[i]].amount>highestBidAmount) {
                highestBidAmount = bids[participant_addresses[i]].amount;
                highestBidIndex = i;
            }
        }

        if (numberOfBidders>0) {
            bids[participant_addresses[highestBidIndex]].winningBid = true;
            return participant_addresses[highestBidIndex];
        }else{
            revert("there were some bids expected, but there are unexpectedly none");
        }
    }

    /// @dev implementation of abstract function to find winner and reset at the end of a cycle
    function doCycleCompleted() internal {
        //distribute the winning bid, as a form of interest to those who didnt collect this cycle
        //since the main kitty funds have been distributed, the remaining contract balance is that
        if (numberOfBidders == 0)
            return;

        //find what the highest bid amount is, so that it can get distributed out
        uint interestToBeDistributed = 0;
        for (uint i = 0; i<participant_addresses.length; i++) {
            if (bids[participant_addresses[i]].exists && bids[participant_addresses[i]].winningBid) {
                interestToBeDistributed = bids[participant_addresses[i]].amount / (numberOfBidders-1);
                continue;
            }
        }

        //setup the withdrawl pattern so that the interest to be distributed can be claimed / retrieved
        for (uint i = 0; i<participant_addresses.length; i++) {
            if (bids[participant_addresses[i]].exists && !bids[participant_addresses[i]].winningBid) {
                bidRefundWithdrawls[participant_addresses[i]] = bids[participant_addresses[i]].amount + interestToBeDistributed;
            }
            bids[participant_addresses[i]] = Bid(0,false,false); //reset for the next cycle
        }
        numberOfBidders = 0;
    }
}