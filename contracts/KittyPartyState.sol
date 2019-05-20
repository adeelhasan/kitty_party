pragma solidity >=0.4.21 <0.6.0;

contract KittyPartyState{

  enum Stages {Open, InProgress, Finished}

  Stages stage = Stages.Open;

  modifier atStage(Stages _stage){
    require(stage == _stage, "at the accepted stage");
    _;
  }

  modifier notAtStage(Stages _stage){
    require(stage != _stage, "not at the accepted stage");
    _;
  }

  function getStage() public view returns (uint){
    return uint(stage);
  }

  function nextStage() internal {
    if (stage != Stages.Finished)
      stage = Stages(uint(stage)+1);
  }
}
