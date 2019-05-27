pragma solidity >=0.4.21 <0.6.0;

// basic library that checks array bounds when doing an operation
library SafeArrayLib{

    /// @dev add to an uint array
    /// @param self Stored array from contract
    /// @param value Uint the value that will get pushed
    function addTo(uint[] storage self, uint value) public{
        self.push(value);
    }

    /// @dev get value at an offset
    /// @param self Stored array from contract
    /// @param offset Uint the offset to get value from
    function getAt(uint[] storage self, uint offset) public view returns(uint){
        require(offset < self.length, "out of bounds");
        return self[offset];
    }

    /// @dev sets value at an offset
    /// @param self Stored array from contract
    /// @param offset Uint the offset to set to
    function setAt(uint[] storage self, uint offset, uint value) public{
        require(offset < self.length, "out of bounds");
        self[offset] = value;
    }
}
