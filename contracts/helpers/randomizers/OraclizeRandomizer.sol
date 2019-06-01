pragma solidity >=0.4.21 <0.6.0;


import "./IRandomizeRangeToArray.sol";
import "./../ExternalUintArrayStorage.sol";
import "./RandomIndicesOraclizeBase.sol";

contract OraclizeRandomizer is RandomIndicesOraclizeBase,IRandomizeRangeToArray {
    address storageLocationAddress;

    event OraclizeResponseReceived(bytes32 id);

    constructor (address _storage) public {
      storageLocationAddress = _storage;
    }

    function randomize(uint numberToSelect, address _arrayStorage) external {
        storageLocationAddress = _arrayStorage;
        initiateQuery(numberToSelect);
    }

    function getRandomizerName() public pure returns(string memory){
      return "oraclizer";
    }

    function doAddUniqueIndexValue(uint _value) internal {
        ExternalUintArrayStorage s = ExternalUintArrayStorage(storageLocationAddress);
        s.add(_value);
    }
}
