pragma solidity >=0.4.21 <0.6.0;

import "./KittyPartyBase.sol";

/**
  In this variant, each cycle of a Kitty has an auction amongst the participants who have not collected as yet
 */
contract KittyPartyAuction is KittyPartyBase
{
    struct Bid{
      uint amount;
      bool winningBid;
      bool exists;
    }

    mapping(address=>Bid) public bids;
    uint public numberOfBidders;

    modifier hasBid(){
      require(bids[msg.sender].exists,"bid exists");
      _;
    }

    modifier hasNotBidAsYet(){
      require(!bids[msg.sender].exists,"bid does not exist");
      _;
    }

    modifier nonZeroBid(){
      require(msg.value > 0, "bid has to be non zero");
      _;
    }

    event BidReceived(address indexed bidder);

    constructor (uint _amount) KittyPartyBase(_amount) public{}

    function receiveBid()
      public
      notInEmergency
      isAParticipant
      hasNotBidAsYet
      nonZeroBid
      hasNotWonACycle
      payable{

      require(numberOfParticipants - cyclesCompleted>1, "should not be the last cycle");
      bids[msg.sender] = Bid(msg.value,false,true);
      numberOfBidders++;
      emit BidReceived(msg.sender);
    }

    //overriden implementation
    function getWinner() internal returns (address){
        //this is the last cycle, so no bidders here, just return the remaining participant who has not won as yet
        if ((numberOfParticipants - cyclesCompleted) <= 1){
          for (uint i = 0; i<numberOfParticipants; i++){
            if (!participants[participant_addresses[i]].has_won_a_cycle)
              return participant_addresses[i];
          }
        }

        uint highestBidIndex = 0;
        uint highestBidAmount = 0;
        for (uint i = 0; i<numberOfParticipants; i++)
        {
          if (bids[participant_addresses[i]].exists && bids[participant_addresses[i]].amount>highestBidAmount){
            highestBidAmount = bids[participant_addresses[i]].amount;
            highestBidIndex = i;
          }
        }

        if (numberOfBidders>0)
        {
          bids[participant_addresses[highestBidIndex]].winningBid = true;
          return participant_addresses[highestBidIndex];
        }
        else
        {
          revert("there were some bids expected, but there are unexpectedly none");
        }
    }

    /** @dev lets the user see their bid, if any */
    function getMyBid() public view returns (uint, bool, bool)
    {
          Bid memory bid = bids[msg.sender];
          if (bid.exists)
            return (bid.amount, bid.winningBid, bid.exists);
          else
            return (0,false,false);
    }

    //cycle has ended, now need to reset internal state for the next cycle
    function cycleCompleted() internal {
      //distribute the winning bid, as a form of interest to those who didnt collect this cycle
      //since the main kitty funds have been distributed, the remaining contract balance is that
      if (numberOfBidders == 0)
        return;

      uint interestToBeDistributed = 0;
      for (uint i = 0; i<participant_addresses.length; i++)
      {
        if (bids[participant_addresses[i]].exists && bids[participant_addresses[i]].winningBid)
        {
            interestToBeDistributed = bids[participant_addresses[i]].amount / (numberOfBidders-1);
            //continue;
        }
      }

      for (uint i = 0; i<participant_addresses.length; i++)
      {
        if (bids[participant_addresses[i]].exists && !bids[participant_addresses[i]].winningBid)
        {
          address aBidderWhoDidntWin = participant_addresses[i];
          address payable lost_bidder_payable = address(uint160(aBidderWhoDidntWin));

          //to address re-entrance vulnerabilities
          bids[participant_addresses[i]].amount = 0;
          lost_bidder_payable.transfer(bids[participant_addresses[i]].amount + interestToBeDistributed);
        }

        //reset for the next cycle
        bids[participant_addresses[i]] = Bid(0,false,false);
      }
      numberOfBidders = 0;
    }

  function refundBidsInEmergency()
    public
    inEmergency
    restrictedToOwner
  {
    //should check the balance first perhaps
    for (uint i = 0; i<participant_addresses.length; i++)
    {
      if (bids[participant_addresses[i]].exists)
      {
          address payable participantAddress = address(uint160(participant_addresses[i]));
          participantAddress.transfer(bids[participant_addresses[i]].amount);
      }
    }
  }

}