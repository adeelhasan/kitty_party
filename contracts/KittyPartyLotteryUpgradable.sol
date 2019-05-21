pragma solidity >=0.4.21 <0.6.0;

import "./KittyPartyLotteryBase.sol";
import "./helpers/RestrictedToOwner.sol";
import "./helpers/ExternalUintArrayStorage.sol";
import "./helpers/randomizers/IRandomizeRangeToArray.sol";

contract KittyPartyLotteryUpgradable is KittyPartyLotteryBase
{
    address public upgradableRandomizerAddress;
    address public externalStorageAddress;

    constructor (uint _amount, address _randomizer, address _storage) KittyPartyLotteryBase(_amount) public{
      upgradableRandomizerAddress = _randomizer;
      externalStorageAddress = _storage;
    }

    function getTypeOfRandomizer() public view returns(string memory){
      IRandomizeRangeToArray randomizer = IRandomizeRangeToArray(upgradableRandomizerAddress);
      return randomizer.getRandomizerName();
    }

    function internal_getWinnerIndex() internal returns (uint){
      ExternalUintArrayStorage localReferenceToStorage = ExternalUintArrayStorage(externalStorageAddress);
      return localReferenceToStorage.getAt(nextWinnerIndex);
    }

    function updateRandomizer(address _randomizer) public restrictedToOwner{
      require(cyclesCompleted == 0,"updating the randomizer only makes sense before any disbursement happens");

      //the legacy randomizer need not be deleted
      upgradableRandomizerAddress = _randomizer;

      //reset the flag so that the lottery can be done again
      hasHappenedOnce = false;
    }

    function enumerateOrderOfWinners() public view returns(uint[] memory){
      ExternalUintArrayStorage localReferenceToStorage = ExternalUintArrayStorage(externalStorageAddress);
      return localReferenceToStorage.getArray();
    }

    function orderOfWinnersLength() public view returns(uint){
      ExternalUintArrayStorage localReferenceToStorage = ExternalUintArrayStorage(externalStorageAddress);
      return localReferenceToStorage.getLength();
    }


    function internal_doInitialLottery() internal{
      IRandomizeRangeToArray randomizer = IRandomizeRangeToArray(upgradableRandomizerAddress);
      randomizer.randomize(numberOfParticipants, externalStorageAddress);
    }
}
