pragma solidity >=0.4.21 <0.6.0;

import "./KittyPartySequential.sol";

// this is ultimately just a sequential draw, however a random order is set at the onset
contract KittyPartyLotteryBase is KittyPartySequential{
    bool internal hasHappenedOnce;  //used to track if the lottery has been done or not

    constructor(uint _amount) KittyPartySequential(_amount) public {}

    //log that the order has been set by a lottery
    event InitialLotteryDone();

    /// @dev override of the base class, gets the winner for this cycle
    function doGetWinner() internal returns (address) {
        require(hasHappenedOnce, "the random distribution needs to have been initialized");
        uint randomWinnerIndex = doGetWinnerIndex();
        return participant_addresses[randomWinnerIndex];
    }

    /// @dev this should be called after the participants are added, and sets up the order of distribution
    function initialLottery()
        public
        atStage(Stages.Started)
        restrictedToOwner
        payable
    {
        require(!hasHappenedOnce, "can only happen once");
        doInitialLottery();
        emit InitialLotteryDone();
        hasHappenedOnce = true;     //make sure that the lottery does not happen again
    }

    /// @dev abstract function to get the next winner index from descendant
    function doGetWinnerIndex() internal returns (uint);

    /// @dev abstract function to do the descendant specific lottery
    function doInitialLottery() internal;
}