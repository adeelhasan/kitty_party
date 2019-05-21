pragma solidity >=0.4.21 <0.6.0;

import "./../ExternalUintArrayStorage.sol";
import "./IRandomizeRangeToArray.sol";


contract BlockRandomizer is IRandomizeRangeToArray{

    function randomize(uint numberToSelect, address arrayStorage) external{
      //for simplicity, will build a reverse ordered sequence, and swap one random indice
      ExternalUintArrayStorage externalStorage = ExternalUintArrayStorage(arrayStorage);
      for (uint i = numberToSelect; i>0; i--){
        externalStorage.add(i-1);
      }

      //random index based on block number
      uint randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%numberToSelect;
      if (randomIndex > 0){
        uint temp = externalStorage.getAt(randomIndex);
        externalStorage.setAt(temp, externalStorage.getAt(0));
        externalStorage.setAt(0, temp);
      }
    }

    function getRandomizerName() public pure returns(string memory){
      return "blockHash";
    }
}
