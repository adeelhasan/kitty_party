pragma solidity >=0.4.21 <0.6.0;

interface IRandomizeRangeToArray{

    /// @dev the abstract function which fills the storage with a range (0 indexed) of unique numbers
    /// @param rangeEnd on a zero based index, the top end of the index to randomize to
    /// @param arrayStorage address of the storage to be used, expected to be ExternalUintArrayStorage
    function randomize(uint rangeEnd, address arrayStorage) external;

    /// @dev the intent for this is to be able to identify the randomizer by a label, this helps testing
    function getRandomizerName() external pure returns(string memory);
}
