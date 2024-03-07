pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

/**
 *  refer: https://book.getfoundry.sh/cheatcodes/etch
 *
 *  @title Sets the bytecode of an address who to code.
 *  Signature
 *  function etch(address who, bytes calldata code) external;
 *
 *  @notice !!!
 *  Please do not directly use vm.etch(address, runtimeCode) to deploy the runtimeCode of xxx.sol file. it's invalid.
 *
 *  There are two ways to deploy it.
 *
 *  1: still use vm.etch, but requires 3 steps
 *
 *  step 1: vm.etch(address target, creationCode)
 *  step2: (bool success, bytes memory runtimeCode) = target.call("") to get runtime code
 *  step3: vm.etch(target, runtimeCode);
 *
 *  2: Deploy using deployCodeTo
 *
 *   deployCodeTo('xxx.sol', bytes calldata args, address target)
 */
contract EtchHelper {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function transferOwner(address newOwner) public {
        owner = newOwner;
    }
}

contract EtchHelper2 {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function transferOwner(address newOwner) public {
        owner = newOwner;
    }
}

contract EtchTest is Test {
    EtchHelper public helper;

    function setUp() public {
        helper = new EtchHelper();
    }

    function test_creationAndRuntimeCode() public {
        bytes memory creationCode = type(EtchHelper).creationCode;
        // vm.etch only put the code on the target address, not actually deployed a callable contract
        vm.etch(address(0), type(EtchHelper).creationCode);
        assertEq(creationCode, address(0).code);

        // really deploy, the code should be runtimeCode, not creationCode
        assertEq(address(helper).code, type(EtchHelper).runtimeCode);
    }

    function test_deployRuntimecode() public {
        _deployTo(address(0), type(EtchHelper).creationCode, "");

        assertEq(address(0).code, type(EtchHelper).runtimeCode);
        assertEq(EtchHelper(address(0)).owner(), address(this));
        EtchHelper(address(0)).transferOwner(address(1));
        assertEq(EtchHelper(address(0)).owner(), address(1));
    }

    function _deployTo(address where, bytes memory creationCode, bytes memory args) internal virtual {
        vm.etch(where, abi.encodePacked(creationCode, args));
        (bool success, bytes memory runtimeCode) = where.call("");
        require(success, "deployCodeTo: Failed to create runtime byte code.");
        vm.etch(where, runtimeCode);
    }
}
