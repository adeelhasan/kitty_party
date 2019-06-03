pragma solidity >=0.4.21 <0.6.0;

import "./KittyPartyLotteryBase.sol";
import "./helpers/randomizers/RandomIndicesOraclizeBase.sol";

/**
    this uses a non upgradable randomizer, through Oraclize
 */
contract KittyPartyLotteryOraclize is RandomIndicesOraclizeBase, KittyPartyLotteryBase
{
    uint[] public randomlySelectedWinners;

    event OraclizeResponseReceived(bytes32 id);

    constructor(uint _amount) KittyPartyLotteryBase(_amount) public {}

    /// @dev the address of the participant in the winners array
    /// @param _index offset into the array
    /// @return address of participant corresponding to the index
    function winnerAt(uint _index) public view returns (address) {
        return participant_addresses[randomlySelectedWinners[_index]];
    }

    /// @dev the length of the array of the winners order, meant to ease testing
    function orderOfWinnersLength() public view returns(uint) {
        return randomlySelectedWinners.length;
    }

    /// @dev abstract function implemented here, will return from the random selection of indices
    function doGetWinnerIndex() internal returns(uint) {
        require(randomlySelectedWinners.length > 0, "the randomized collection is not valid as yet");
        return randomlySelectedWinners[nextWinnerIndex];
    }

    /// @dev abstract function implemented here, will initiate the lottery
    function doInitialLottery() internal {
        initiateOraclizeQuery(numberOfParticipants);
    }

    /// @dev abstract function implemented here, nothing happens in this case
    function doWithdrawMyRefund() internal {}

    function doAddUniqueIndexValue(uint _value) internal {
       randomlySelectedWinners.push(_value);
    }

}
