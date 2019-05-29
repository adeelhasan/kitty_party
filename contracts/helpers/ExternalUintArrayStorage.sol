pragma solidity >=0.4.21 <0.6.0;

import "./RestrictedToOwner.sol";
import "./SafeArrayLib.sol";

/**
    storage which can addressable.
    links to SafeArrayLib which has bounds checking
 */
contract ExternalUintArrayStorage {

    using SafeArrayLib for uint[];
    uint[] uintArray;

    /// @dev dumps out the array
    /// @return uint[]
    function getArray() public view returns (uint[] memory array_) {
        array_ = new uint[] (uintArray.length);
        for (uint i = 0; i < uintArray.length; i++){
            array_[i] = uintArray[i];
        }
    }

    /// @dev sets internal storage to be the array passed in
    /// @param _array uint[] to set itself to
    function setFromArray(uint[] memory _array) public {
        require(uintArray.length==0, "array has to be empty to be overwritten");
        for (uint i = 0; i < _array.length; i++){
            uintArray[i] = _array[i];
        }
    }

    /// @dev appends to the storage
    /// @param _value value to be pushed to array
    function add(uint _value) public {
        uintArray.addTo(_value);
    }

    /// @dev getLength gets array length
    /// @param _index zero based offset in the array
    /// @param _value uint value to put into array
    function setAt(uint _index, uint _value) public {
        uintArray.setAt(_index,_value);
    }

    /// @dev gets array length
    /// @param _index zero based offset in the array
    /// @param return uint value at the offset
    function getAt(uint _index) public view returns(uint) {
        return uintArray.getAt(_index);
    }

    /// @dev getLength gets array length
    /// @return length
    function getLength() public view returns(uint) {
        return uintArray.length;
    }
}
