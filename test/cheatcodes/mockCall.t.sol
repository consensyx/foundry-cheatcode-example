pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

/**
 *  refer: https://book.getfoundry.sh/cheatcodes/mock-call
 *
 *  @notice Mockcall will not actually call the function of the contract at the 'where' address,
 *  even if the function at this address does have some logic code
 *  @notice Although mockcall will not execute the code on the function at 'where' address, if the
 *  function is a public variable (storage), it can modify the value of the storage.
 *
 *  Signature
 *
 *  function mockCall(address where, bytes calldata data, bytes calldata retdata) external;
 *
 *  function mockCall(
 *      address where,
 *      uint256 value,
 *      bytes calldata data,
 *      bytes calldata retdata
 *   ) external;
 *
 */

/// @notice mockCall will not really call the functio
contract MockCallExample1 {
    function mockMultiReturn(uint256) public pure returns (uint256, bool, bytes memory, string memory) {}
}

contract MockCallExample2 {
    uint256 public number = 10;

    receive() external payable {}

    function pay() external payable returns (uint256) {}
}

contract MockCallTest is Test {
    MockCallExample1 public example1;
    MockCallExample2 public example2;

    function setUp() public {
        example1 = new MockCallExample1();
        example2 = new MockCallExample2();
    }

    function test_mockCallMultiReturn() public {
        vm.mockCall(
            address(example1),
            abi.encodeWithSelector(MockCallExample1.mockMultiReturn.selector, 1),
            abi.encode(0, true, bytes("hello"), "world")
        );
        (uint256 ret1, bool ret2, bytes memory ret3, string memory ret4) = example1.mockMultiReturn(1);
        assertEq(ret1, 0);
        assertEq(ret2, true);
        assertEq(ret3, bytes("hello"));
        assertEq(ret4, "world");
        assertEq(ret4, "world");
    }

    function test_mockCallPubicVariable() public {
        // can't use 'abi.encodeWithSelector(MockCallExample2.number.selector))'
        vm.mockCall(address(example2), abi.encodeWithSelector(bytes4(keccak256("number()"))), abi.encode(5));

        // 'mockCall' modify the storage value at 'where' address
        assertEq(example2.number(), 5);
    }

    function test_mockCallWithValue() public {
        vm.mockCall(
            address(example2), 1 ether, abi.encodeWithSelector(MockCallExample2.pay.selector), abi.encode(1 ether)
        );
        // the value should match msg.value
        assertEq(example2.pay{value: 1 ether}(), 1 ether);

        // if we have 2nd mockCall, the msg.value = 10 ether
        vm.mockCall(
            address(example2), 10 ether, abi.encodeWithSelector(MockCallExample2.pay.selector), abi.encode(10 ether)
        );
        assertEq(example2.pay{value: 10 ether}(), 10 ether);

        // now we find we still call with msg.value = 1 ether, it still worked
        // It seems that ‘mockCall’ will save the data of multiple mock calls below.
        // Only if there is a match, the corresponding return data will be return.
        assertEq(example2.pay{value: 1 ether}(), 1 ether);
    }
}
