pragma solidity >=0.4.21 <0.6.0;

import "./../ExternalArrayStorage.sol";
import "./IRandomizeRangeToArray.sol";


contract BlockRandomizer is IRandomizeRangeToArray{
    function randomize(uint numberToSelect, address arrayStorage) external{
      //for simplicity, this is just sequential for now
      ExternalArrayStorage externalStorage = ExternalArrayStorage(arrayStorage);
      for (uint i = 0; i<numberToSelect; i++){
        externalStorage.setValue(i,i);
      }
    }

    function getRandomizerName() public pure returns(string memory){
      return "blockHash";
    }
}
