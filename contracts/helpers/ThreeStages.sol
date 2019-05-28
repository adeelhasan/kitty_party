pragma solidity >=0.4.21 <0.6.0;

/** 
    simple state manager, moves between three of them
*/
contract ThreeStages {

    enum Stages {NotStarted, Started, Finished}
    Stages stage;

    /// @dev check if at a particular stage
    modifier atStage(Stages _stage) {
        require(stage == _stage, "at the accepted stage");
        _;
    }

    /// @dev ensure we are not at a stage
    modifier notAtStage(Stages _stage) {
      require(stage != _stage, "not at the accepted stage");
      _;
    }

    constructor () public {
        stage = Stages.NotStarted;
    }

    /// @dev the current stage we are at
    function getStage() public view returns (uint) {
        return uint(stage);
    }

    /// @dev move on to the next stage, do nothing if already at the end
    function nextStage() internal {
        if (stage != Stages.Finished) {
            stage = Stages(uint(stage)+1);
        }
    }
}