pragma solidity >=0.4.21 <0.6.0;

import "./RestrictedToOwner.sol";

//storage which is separated out, and also protected
contract ExternalArrayStorage is RestrictedToOwner{
    uint[] uintArray;

    function getUintArray() public view returns (uint[] memory array_) {
        array_ = new uint[] (uintArray.length);
        for(uint i = 0; i < uintArray.length; i++){
            array_[i] = uintArray[i];
        }
    }

    function setUintArray(uint[] memory _array) public restrictedToOwner {
        for(uint i = 0; i < _array.length; i++){
            uintArray[i] = _array[i];
        }
    }

    function addToStorage(uint i) public restrictedToOwner{
        uintArray.push(i);
    }

    function setValue(uint _index, uint _value) public restrictedToOwner{
        uintArray[_index] = _value;
    }

    function getValueAt(uint _index) public view restrictedToOwner returns(uint){
        return uintArray[_index];
    }

    function getLength() public view returns(uint){
        return uintArray.length;
    }
}
