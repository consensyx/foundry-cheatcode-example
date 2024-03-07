pragma solidity 0.8.23;

contract DeployCodeHelper {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function transferOwner(address newOwner) public {
        owner = newOwner;
    }
}
