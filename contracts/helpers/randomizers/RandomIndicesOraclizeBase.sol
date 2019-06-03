pragma solidity >=0.4.21 <0.6.0;


import "./oraclizeAPI.sol";

/**
    This is the wrapper to make and receive oraclize calls
    its limited to making a call to get a random list of array indexes
    however the call used gives back a non unique list
 */
contract RandomIndicesOraclizeBase is usingOraclize{

    /// this stores the unique values found during processing results
    mapping(uint => bool) public uniqueUintsMap;

    /// meant to track which calls are expected back at callback
    mapping(bytes32=>bool) validIds;

    event OraclizeResponseReceived();

    /// @dev this is called from the oraclize service, contract has to have enough balance to cover the gas used
    /// @param myId Bytes32 was assigned when the call was initiated, meant as a soft security check
    /// @param result String the result of whatever function or lookup was called from "initiateQuery"
    function __callback(bytes32 myid, string memory result) public {
        if (msg.sender != oraclize_cbAddress()) revert("oraclize callback not from expected source");
        if (!validIds[myid]) revert("the received queryId was not recognized as valid");

        validIds[myid] = false;
        emit OraclizeResponseReceived();

        bytes memory stringInBytes = bytes(result);
        for(uint i = 0; i<stringInBytes.length; i++) {
            if ((uint(uint8(stringInBytes[i])) >= 48) && (uint(uint8(stringInBytes[i])) <= 57)) {
            if (!uniqueUintsMap[uint(uint8(stringInBytes[i]))]) {
                    uniqueUintsMap[uint(uint8(stringInBytes[i]))] = true;
                    doAddUniqueIndexValue(uint(uint8(stringInBytes[i])-48));
                }
            }
        }
    }

    /// @dev send out the query
    /// @param arrayLength Uint the upper bound value of the array index to choose within
    function initiateOraclizeQuery(uint arrayLength) internal {
        //the oraclize query returns x random numbers in a range of y. however these are not
        //unique selections, so to ensure that we get a set of uniques, have to get a multiple of the count
        string memory query_string = strConcat("RandomInteger[",uint2str(arrayLength-1),",",uint2str(arrayLength*5),"]");
        bytes32 queryId = oraclize_query("WolframAlpha", query_string, 500000);
        validIds[queryId] = true;
    }

    /// @dev since the storage can be different in descendant classes, the call to storage is abstracted out
    function doAddUniqueIndexValue(uint _value) internal;
}
