pragma solidity >=0.4.21 <0.6.0;

/**
    a way to check if a function is being called by the designated address of record
    descend from this class to make use of it
 */
contract RestrictedToOwner{
    address private _owner;

    modifier restrictedToOwner() {
        require(msg.sender == _owner, "restricted to owner");
        _;
    }

    constructor() public{
        _owner = msg.sender;
    }

    function owner() public view returns(address){
        return _owner;
    }
}

