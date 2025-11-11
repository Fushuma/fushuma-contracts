// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title MinimalProxy
 * @dev Ultra-simple proxy for zkEVM compatibility
 * Based on EIP-1967 but simplified for zkEVM gas constraints
 */
contract MinimalProxy {
    // EIP-1967 implementation slot
    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    
    event Upgraded(address indexed implementation);
    
    constructor(address _implementation) {
        assembly {
            sstore(IMPLEMENTATION_SLOT, _implementation)
        }
        emit Upgraded(_implementation);
    }
    
    fallback() external payable {
        assembly {
            let impl := sload(IMPLEMENTATION_SLOT)
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    
    receive() external payable {}
}
