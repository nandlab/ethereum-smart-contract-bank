// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


/**
 * @title SimpleUpgradableProxy
 * @dev Proxy which forwards function calls to a delegate contract.
 * This contract is based on the proxy delegate pattern,
 * see: https://fravoll.github.io/solidity-patterns/proxy_delegate.html
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract SimpleUpgradableProxy {

    address public delegate;
    address private owner = msg.sender;

    fallback() payable external {
        assembly {
            // Load the delegate address into a local variable
            let _target := sload(delegate.slot)

            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), _target, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function upgradeDelegate(address _newDelegateAddress) external {
        require(msg.sender == owner);
        delegate = _newDelegateAddress;
    }

    receive() payable external {
        // You should not send ETH to this receive() function.
        // This function is only added to make the compiler happy.
    }
}
