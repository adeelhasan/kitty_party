pragma solidity >=0.4.21 <0.6.0;


import "./IRandomizeRangeToArray.sol";
import "./../ExternalUintArrayStorage.sol";
import "./RandomIndicesOraclizeBase.sol";

contract OraclizeRandomizer is RandomIndicesOraclizeBase,IRandomizeRangeToArray {
    address storageLocationAddress;

    constructor (address _storage) public {
      storageLocationAddress = _storage;
    }

    /// @dev this will start the oraclize query
    /// @param numberToSelect Uint the length of the array whose indices need randomization
    /// @param _arrayStorage Address the location of the storage to store results at
    function randomize(uint numberToSelect, address _arrayStorage) external {
        storageLocationAddress = _arrayStorage;
        initiateOraclizeQuery(numberToSelect);
    }

    function getRandomizerName() public pure returns(string memory){
      return "oraclizer";
    }

    /// @dev abstract implementation, store the result of a calculation done at base level
    /// @param _value Uint the value to be stored
    function doAddUniqueIndexValue(uint _value) internal {
        ExternalUintArrayStorage s = ExternalUintArrayStorage(storageLocationAddress);
        s.add(_value);
    }
}
