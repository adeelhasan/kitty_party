pragma solidity >=0.4.21 <0.6.0;

import "./KittyPartyLotteryBase.sol";
import "./helpers/randomizers/oraclizeAPI.sol";

//this uses a fixed randomizer, through Oraclize
contract KittyPartyLotteryOraclize is usingOraclize, KittyPartyLotteryBase
{
  mapping(uint => bool) public uniqueWinnersMap;
  uint[] public randomlySelectedWinners;

  event OraclizeResponseReceived(bytes32 id);

  constructor (uint _amount) KittyPartyLotteryBase(_amount) public{}

  function doGetWinnerIndex() internal returns(uint){
    require(randomlySelectedWinners.length > 0, "the randomized collection is not valid as yet");
    return randomlySelectedWinners[nextWinnerIndex];
  }

  function __callback(bytes32 myid, string memory result) public {
    if (msg.sender != oraclize_cbAddress())
      revert("oraclize callback not from expected source");

    bytes memory stringInBytes = bytes(result);
    for(uint i = 0; i<stringInBytes.length; i++){
      if ((uint(uint8(stringInBytes[i])) >= 48) && (uint(uint8(stringInBytes[i])) <= 57)){
        if (!uniqueWinnersMap[uint(uint8(stringInBytes[i]))]){
                uniqueWinnersMap[uint(uint8(stringInBytes[i]))] = true;
                randomlySelectedWinners.push(uint(uint8(stringInBytes[i])-48));
          }
        }
      }
      emit OraclizeResponseReceived(myid);
  }

  function doInitialLottery() internal{
      string memory query_string = strConcat("RandomInteger[",uint2str(numberOfParticipants-1),",",uint2str(numberOfParticipants*5),"]");
      oraclize_query("WolframAlpha", query_string);
  }

  function doWithdrawMyRefund() internal{
      //nothing happens in this case
  }
}
