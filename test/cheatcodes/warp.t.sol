pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

contract WarpTest is Test {
    function setUp() public {}

    function testFuzz_warpTimestamp(uint256 timestamp) public {
        vm.warp(timestamp);
        assertEq(block.timestamp, timestamp);
    }
}
