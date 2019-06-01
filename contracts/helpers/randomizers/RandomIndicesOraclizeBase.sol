pragma solidity >=0.4.21 <0.6.0;


import "./oraclizeAPI.sol";

contract RandomIndicesOraclizeBase is usingOraclize{
    mapping(uint => bool) public uniqueWinnersMap;

    event OraclizeResponseReceived(bytes32 id);

    constructor () public {}

    function __callback(bytes32 myid, string memory result) public {
       if (msg.sender != oraclize_cbAddress())
         revert("oraclize callback not from expected source");

      bytes memory stringInBytes = bytes(result);
      for(uint i = 0; i<stringInBytes.length; i++){
        if ((uint(uint8(stringInBytes[i])) >= 48) && (uint(uint8(stringInBytes[i])) <= 57)){
          if (!uniqueWinnersMap[uint(uint8(stringInBytes[i]))]){
                  uniqueWinnersMap[uint(uint8(stringInBytes[i]))] = true;
                  doAddUniqueIndexValue(uint(uint8(stringInBytes[i])-48));
            }
          }
       }

        emit OraclizeResponseReceived(myid);
    }

    function initiateQuery(uint arrayLength) internal {
        //the oraclize query returns x random numbers in a range of y. however these are not
        //unique selections, so to ensure that we get a set of uniques, have to get a multiple of the count
        string memory query_string = strConcat("RandomInteger[",uint2str(arrayLength-1),",",uint2str(arrayLength*5),"]");
        oraclize_query("WolframAlpha", query_string, 500000);
    }

    function doAddUniqueIndexValue(uint _value) internal;
}
