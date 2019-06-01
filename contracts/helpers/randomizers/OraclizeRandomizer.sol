pragma solidity >=0.4.21 <0.6.0;


import "./IRandomizeRangeToArray.sol";
import "./../ExternalUintArrayStorage.sol";
import "./oraclizeAPI.sol";

contract OraclizeRandomizer is IRandomizeRangeToArray, usingOraclize{
    mapping(uint => bool) public uniqueWinnersMap;
    address storageLocationAddress;

    event OraclizeResponseReceived(bytes32 id);

    constructor (address _storage) public {
      storageLocationAddress = _storage;
    }

    function __callback(bytes32 myid, string memory result) public {
       if (msg.sender != oraclize_cbAddress())
         revert("oraclize callback not from expected source");

      bytes memory stringInBytes = bytes(result);
      ExternalUintArrayStorage currentData = ExternalUintArrayStorage(storageLocationAddress);

      for(uint i = 0; i<stringInBytes.length; i++){
        if ((uint(uint8(stringInBytes[i])) >= 48) && (uint(uint8(stringInBytes[i])) <= 57)){
          if (!uniqueWinnersMap[uint(uint8(stringInBytes[i]))]){
                  uniqueWinnersMap[uint(uint8(stringInBytes[i]))] = true;
                  currentData.add(uint(uint8(stringInBytes[i])-48));
            }
          }
       }

        emit OraclizeResponseReceived(myid);
    }

    function randomize(uint numberToSelect, address _arrayStorage) external {
        storageLocationAddress = _arrayStorage;

        //the oraclize query returns x random numbers in a range of y. however these are not
        //unique selections, so to ensure that we get a set of uniques, have to get a multiple of the count
        string memory query_string = strConcat("RandomInteger[",uint2str(numberToSelect-1),",",uint2str(numberToSelect*5),"]");
        oraclize_query("WolframAlpha", query_string);
    }

    function getRandomizerName() public pure returns(string memory){
      return "oraclizer";
    }
}
