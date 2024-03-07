pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../../src/mocks/deployCodeHelper.sol";

/**
 *  refer: https://book.getfoundry.sh/reference/forge-std/deployCodeTo
 *
 *  @notice deployCodeTo is essentially done by calling vm.getCode and vm.etch two cheatcodes
 *
 *  1: VM::getCode("a.sol"): get the creationcode of a.sol
 *
 *  2: vm.etch(): deploys the runtimecode corresponding to a.sol
 *
 */
contract DeployCodeToTest is Test {
    function setUp() public {}

    function test_deployCodeByRuntimecode() public {
        deployCodeTo("DeployCodeHelper.sol", abi.encode(msg.sender), address(0));

        assertEq(DeployCodeHelper(address(0)).owner(), msg.sender);

        DeployCodeHelper(address(0)).transferOwner(address(1));

        assertEq(DeployCodeHelper(address(0)).owner(), address(1));
    }
}
