pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";

contract Nonce {
    uint256 public nonce;

    function setNonce(uint256 newNonce) public {
        nonce = newNonce;
    }
}

contract SetupParentTest is Test {
    Nonce public nonce;

    function setUp() public virtual {
        nonce = new Nonce();
        nonce.setNonce(1234);
    }
}

contract SetupTest is SetupParentTest {
    function setUp() public override {
        nonce = new Nonce();
        nonce.setNonce(2345);
    }

    function testFuzz_setup(uint256 newNonce) public {
        nonce.setNonce(newNonce);
        assertEq(nonce.nonce(), newNonce);
    }
}
