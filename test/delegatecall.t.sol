pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {Delegator} from "../src/Delegatecall.sol";

contract DelegatorImplDemo1 {
    address public owner;

    mapping(address => uint256) public counter;

    function initialize(address _owner) public {
        owner = _owner;
    }

    function increaseCount() public {
        counter[msg.sender] += 1;
    }

    function checkCounter() public view returns (bool) {
        return counter[msg.sender] > 3;
    }
}

contract DelegatorImplDemo2 {
    address public owner;
    mapping(address => uint256) public counter;

    function initialize(address _owner) public {
        owner = _owner;
    }

    function increaseCount() public {
        counter[msg.sender] += 1;
    }

    function checkCounter() public view returns (bool) {
        return counter[msg.sender] > 10;
    }
}

contract DelegatorCallTest is Test {
    Delegator public delegator;

    address public ADMIN = address(101);

    function setUp() public {
        vm.startPrank(ADMIN);
        delegator = new Delegator(
            ADMIN, address(new DelegatorImplDemo1()), abi.encode(DelegatorImplDemo2.initialize.selector, ADMIN)
        );
        vm.stopPrank();
        console.log("setup in DelegatorCallTest");
    }

    function test_DelegatorCall() public {
        DelegatorImplDemo1 impl1 = DelegatorImplDemo1(address(delegator));

        for (uint256 i = 0; i < 5; i++) {
            impl1.increaseCount();
        }

        // current counter is 5, checkCounter in impl1 should be true
        assertTrue(impl1.checkCounter());

        uint256 beforeCounter = impl1.counter(msg.sender);
        vm.startPrank(ADMIN);
        delegator.upgradeToAndCall(
            address(new DelegatorImplDemo2()), abi.encode(DelegatorImplDemo2.initialize.selector, ADMIN)
        );

        vm.stopPrank();

        DelegatorImplDemo2 impl2 = DelegatorImplDemo2(address(delegator));

        // upgrade implementation will not affect the storage layout and value in Delegator contract
        assertEq(beforeCounter, impl2.counter(msg.sender));

        // current counter is 5, checkCounter in impl2 should be false
        assertFalse(impl1.checkCounter());

        for (uint256 i = 0; i < 10; i++) {
            impl1.increaseCount();
        }

        // current counter is 15 (5 + 10), checkCounter in impl2 should be true
        assertTrue(impl2.checkCounter());
    }
}
