pragma solidity 0.8.23;

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage s) {
        assembly {
            s.slot := slot
        }
    }
}

abstract contract Proxy {
    function _fallback(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    fallback() external payable virtual {
        _fallback(_implementation());
    }

    function _implementation() internal view virtual returns (address) {}
}

/// @title An example of proxy contract implemented by delegatecall
contract Delegator is Proxy {
    // keccak-256("eip1967.proxy.implementation") - 1
    bytes32 internal constant implementation_slot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    // keccak-256("eip1967.proxy.admin") - 1
    bytes32 internal constant admin_slot = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event Upgraded(address indexed implementation);

    modifier onlyAmin() {
        require(msg.sender == getAdmin(), "Only Admin");
        _;
    }

    constructor(address admin, address impl, bytes memory data) {
        require(admin != address(0), "Zero Address");
        _setAdmin(admin);
        upgradeToAndCall(impl, data);
    }

    function upgradeToAndCall(address impl, bytes memory data) public onlyAmin {
        _upgradeTo(impl);

        if (data.length > 0) {
            (bool success,) = impl.delegatecall(data);

            require(success, "upgradeToAndCall failed");
        }
    }

    function getImplementation() public view returns (address) {
        return _implementation();
    }

    function getAdmin() public view returns (address) {
        return _admin();
    }

    function _implementation() internal view override returns (address impl) {
        return StorageSlot.getAddressSlot(implementation_slot).value;
    }

    function _admin() internal view returns (address admin) {
        return StorageSlot.getAddressSlot(admin_slot).value;
    }

    function _setImplementation(address newImplementation) internal {
        StorageSlot.getAddressSlot(implementation_slot).value = newImplementation;
    }

    function _setAdmin(address newAdmin) internal {
        StorageSlot.getAddressSlot(admin_slot).value = newAdmin;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    receive() external payable virtual {}
}
