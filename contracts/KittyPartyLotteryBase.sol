pragma solidity >=0.4.21 <0.6.0;

import "./KittyPartySequential.sol";

contract KittyPartyLotteryBase is KittyPartySequential{
  bool internal hasHappenedOnce;

  constructor (uint _amount) KittyPartySequential(_amount) public{}

  event InitialLotteryDone();

  function getWinner() internal returns (address){
    require(hasHappenedOnce, "the random distribution needs to have been initialized");
    uint randomWinnerIndex = internal_getWinnerIndex();
    participants[participant_addresses[randomWinnerIndex]].has_won_a_cycle = true;
    address winner = participant_addresses[nextWinnerIndex];
    return winner;
  }

  function doInitialLottery()
   public
   atStage(Stages.InProgress)
   restrictedToOwner
   payable
   {
    require(cyclesCompleted == 0,"the lottery needs to happen before any cycle has completed");
    require(!hasHappenedOnce, "can only happen once");

    internal_doInitialLottery();

    emit InitialLotteryDone();
    hasHappenedOnce = true;
  }

  function internal_getWinnerIndex() internal returns (uint);
  function internal_doInitialLottery() internal;
}