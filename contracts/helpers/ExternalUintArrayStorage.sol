pragma solidity >=0.4.21 <0.6.0;

import "./RestrictedToOwner.sol";
import "./SafeArrayLib.sol";

//storage which is separated out
contract ExternalUintArrayStorage {

    using SafeArrayLib for uint[];
    uint[] uintArray;

    function getArray() public view returns (uint[] memory array_){
        array_ = new uint[] (uintArray.length);
        for(uint i = 0; i < uintArray.length; i++){
            array_[i] = uintArray[i];
        }
    }

    function setFromArray(uint[] memory _array) public{
        require(uintArray.length==0, "array has to be empty to be overwritten");
        for(uint i = 0; i < _array.length; i++){
            uintArray[i] = _array[i];
        }
    }

    function add(uint i) public{
        uintArray.addTo(i);
    }

    function setAt(uint _index, uint _value) public{
        uintArray.setAt(_index,_value);
    }

    function getAt(uint _index) public view returns(uint){
        return uintArray.getAt(_index);
    }

    function getLength() public view returns(uint){
        return uintArray.length;
    }
}
