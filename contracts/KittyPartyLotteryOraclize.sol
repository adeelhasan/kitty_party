pragma solidity >=0.4.21 <0.6.0;

import "./KittyPartyLotteryBase.sol";
import "./helpers/randomizers/oraclizeAPI.sol";

/**
    this uses a non upgradable randomizer, through Oraclize
 */
contract KittyPartyLotteryOraclize is usingOraclize, KittyPartyLotteryBase
{
    mapping(uint => bool) public uniqueWinnersMap;
    uint[] public randomlySelectedWinners;

    event OraclizeResponseReceived(bytes32 id);

    constructor(uint _amount) KittyPartyLotteryBase(_amount) public {}

    /// @dev process the result from Oraclize
    /// @param myid this is used as a soft check in case something else may call this method
    /// @param result this is the actual result as a string
    function __callback(bytes32 myid, string memory result) public {
        if (msg.sender != oraclize_cbAddress())
        revert("oraclize callback not from expected source");

        //parse the result, taking out the numbers
        bytes memory stringInBytes = bytes(result);
        for(uint i = 0; i<stringInBytes.length; i++) {
            if ((uint(uint8(stringInBytes[i])) >= 48) && (uint(uint8(stringInBytes[i])) <= 57)) {
                if (!uniqueWinnersMap[uint(uint8(stringInBytes[i]))]){
                        uniqueWinnersMap[uint(uint8(stringInBytes[i]))] = true;
                        randomlySelectedWinners.push(uint(uint8(stringInBytes[i])-48));
                }
            }
        }
        emit OraclizeResponseReceived(myid);
    }

    /// @dev the address of the participant in the winners array
    /// @param _index offset into the array
    /// @return address account of participant corresponding to the index
    function winnerAt(uint _index) public returns (address) {
        uint participant_index = randomlySelectedWinners[_index];
        return participant_addresses[participant_index];
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
        string memory query_string = strConcat("RandomInteger[",uint2str(numberOfParticipants-1),",",uint2str(numberOfParticipants*5),"]");
        oraclize_query("WolframAlpha", query_string);
    }

    /// @dev abstract function implemented here, nothing happens in this case
    function doWithdrawMyRefund() internal {}
}
