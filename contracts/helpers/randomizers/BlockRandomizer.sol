pragma solidity >=0.4.21 <0.6.0;

import "./../ExternalUintArrayStorage.sol";
import "./IRandomizeRangeToArray.sol";

/**
    will implement IRandomizeRangeToArray based on something simple
    not meant to be a secure randomizer
 */
contract BlockRandomizer is IRandomizeRangeToArray {

    /// @dev fills storage with a randomly sorted array of unique index values within a range
    /// @param rangeEnd uint how many array index values
    /// @param arrayStorage address where the randomization results will be kept
    function randomize(uint rangeEnd, address arrayStorage) external {
        //for simplicity, will build a reverse ordered sequence, and swap one random indice
        ExternalUintArrayStorage externalStorage = ExternalUintArrayStorage(arrayStorage);
        for (uint i = rangeEnd; i>0; i--) {
            externalStorage.add(i-1);
        }

        //random index based on block number
        uint randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%rangeEnd;
        if (randomIndex > 0) {
            uint temp = externalStorage.getAt(randomIndex);
            externalStorage.setAt(temp, externalStorage.getAt(0));
            externalStorage.setAt(0, temp);
        }
    }

    /// @dev meant to return an identitifer, to aid in testing; part of the implementation
    /// @return string
    function getRandomizerName() public pure returns(string memory) {
        return "blockHash";
    }
}
