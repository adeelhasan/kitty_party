pragma solidity >=0.4.21 <0.6.0;


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

