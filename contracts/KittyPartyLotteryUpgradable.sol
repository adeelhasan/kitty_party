pragma solidity >=0.4.21 <0.6.0;

import "./KittyPartyLotteryBase.sol";
import "./helpers/RestrictedToOwner.sol";
import "./helpers/ExternalUintArrayStorage.sol";
import "./helpers/randomizers/IRandomizeRangeToArray.sol";

/**
    This contract has a randomizer which can be swapped out
    The storage for the randomized array of winners can also be switched out
    It determines the winner of a cycle based on lottery done at the onset
 */
contract KittyPartyLotteryUpgradable is KittyPartyLotteryBase
{
    address public upgradableRandomizerAddress;
    address public externalStorageAddress;

    /// @dev Constructor
    /// @param _amount required contribution value in wei
    /// @param _randomizer address of a contract which implements IRandomizeRageToArray
    /// @param _storage address of storage for the result of the randomization
    constructor(uint _amount, address _randomizer, address _storage) KittyPartyLotteryBase(_amount) public {
        upgradableRandomizerAddress = _randomizer;
        externalStorageAddress = _storage;
    }

    /// @dev used to get a descriptor helpful in testing
    function getTypeOfRandomizer() public view returns(string memory) {
        IRandomizeRangeToArray randomizer = IRandomizeRangeToArray(upgradableRandomizerAddress);
        return randomizer.getRandomizerName();
    }

    /// @dev change the pointer to another randomizer
    function updateRandomizer(address _randomizer) public restrictedToOwner {
        //the legacy randomizer need not be deleted
        upgradableRandomizerAddress = _randomizer;

        //reset the flag so that the lottery can be done again
        hasHappenedOnce = false;
    }

    /// @dev this will give a list of what the randomizer did, meant to ease developmnet
    function enumerateOrderOfWinners() public view returns(uint[] memory) {
        ExternalUintArrayStorage localReferenceToStorage = ExternalUintArrayStorage(externalStorageAddress);
        return localReferenceToStorage.getArray();
    }

    /// @dev the length of the array of the winners order, meant to ease testing
    function orderOfWinnersLength() public view returns(uint) {
        ExternalUintArrayStorage localReferenceToStorage = ExternalUintArrayStorage(externalStorageAddress);
        return localReferenceToStorage.getLength();
    }

    /// @dev the address of the participant in the winners array
    /// @param _index offset into the array
    /// @return address the account that is the winner
    function winnerAt(uint _index) public view returns (address) {
        ExternalUintArrayStorage localReferenceToStorage = ExternalUintArrayStorage(externalStorageAddress);
        uint participant_index = localReferenceToStorage.getAt(_index);
        return participant_addresses[participant_index];
    }

    /// @dev return the next winner index, based on the random pick stored in externalStorageAddress
    function doGetWinnerIndex() internal returns (uint) {
        ExternalUintArrayStorage localReferenceToStorage = ExternalUintArrayStorage(externalStorageAddress);
        return localReferenceToStorage.getAt(nextWinnerIndex);
    }

    /// @dev abstract function implementation, that makes the randomizer fill out the results
    function doInitialLottery() internal {
        IRandomizeRangeToArray randomizer = IRandomizeRangeToArray(upgradableRandomizerAddress);
        randomizer.randomize(numberOfParticipants, externalStorageAddress);
    }

    /// @dev abstract function implementation, nothing here though
    function doWithdrawMyRefund() internal {}
}
