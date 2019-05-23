pragma solidity >=0.4.21 <0.6.0;

import "./KittyPartyBase.sol";

contract KittyPartySequential is KittyPartyBase
{
    uint nextWinnerIndex;

    constructor (uint _amount) KittyPartyBase(_amount) public{}

    function doGetWinner() internal returns (address){
      address winner = participant_addresses[nextWinnerIndex];
      return winner;
    }

    function doCycleCompleted() internal{
      nextWinnerIndex++;
    }

}



