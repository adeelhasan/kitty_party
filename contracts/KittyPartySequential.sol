pragma solidity >=0.4.21 <0.6.0;

import "./KittyPartyBase.sol";

/**
    This variation simply sets the winners to be the order in which accounts joined the kitty
 */
contract KittyPartySequential is KittyPartyBase
{
    uint nextWinnerIndex;   //the index into the participant addresses which is the next winner

    /// @dev Constructor
    /// @param _amount required contribution value in wei
    constructor(uint _amount) KittyPartyBase(_amount) public {}

    /// @dev get the winner
    /// @return address 
    function doGetWinner() internal returns (address){
        address winner = participant_addresses[nextWinnerIndex];
        return winner;
    }

    /// @dev abstract implementation, simply move the index forward
    function doCycleCompleted() internal{
        nextWinnerIndex++;
    }

    /// @dev abstract function implementation, nothing here though
    function doWithdrawMyRefund() internal {}

}



