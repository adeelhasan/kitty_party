pragma solidity >=0.4.21 <0.6.0;

interface IRandomizeRangeToArray{
  //the abstract function which fills the storage with a range (0 indexed) of unique numbers
  function randomize(uint rangeEnd, address arrayStorage) external;

  //the intent for this is to be able to identify the randomizer by a label
  function getRandomizerName() external pure returns(string memory);
}
