pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

contract PrankHelper {
    function checkMsgSenderAndOrigin(address sender, address origin) public view returns (bool, bool) {
        return (msg.sender == sender, tx.origin == origin);
    }
}

contract PrankTest is Test {
    PrankHelper public pranker;

    function setUp() public {
        pranker = new PrankHelper();
    }

    function test_msgSenderAndOrigin() public {
        // only set msg.sender
        vm.prank(address(0));
        (bool t1, bool t2) = pranker.checkMsgSenderAndOrigin(address(0), address(0));
        assertTrue(t1);
        assertFalse(t2);

        // set msg.sender and tx.origin
        vm.prank(address(0), address(0));
        (t1, t2) = pranker.checkMsgSenderAndOrigin(address(0), address(0));
        assertTrue(t1);
        assertTrue(t2);
    }
}
