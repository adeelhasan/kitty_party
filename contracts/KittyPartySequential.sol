pragma solidity >=0.4.21 <0.6.0;

import "./KittyPartyBase.sol";

contract KittyPartySequential is KittyPartyBase
{
    uint nextWinnerIndex;

    constructor (uint _amount) KittyPartyBase(_amount) public
    {}

    function getWinner() internal returns (address){
      participants[participant_addresses[nextWinnerIndex]].has_won_a_cycle = true;
      address winner = participant_addresses[nextWinnerIndex];
      return winner;
    }


    function cycleCompleted() internal {
      nextWinnerIndex++;
    }
}



