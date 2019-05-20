pragma solidity >=0.4.21 <0.6.0;


contract RestrictedToOwner{
  address private owner;

  modifier restrictedToOwner() {
    require(msg.sender == owner, "restricted to owner");
    _;
  }
  constructor() public{
    owner = msg.sender;
  }
}

