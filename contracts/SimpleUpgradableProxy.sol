// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/proxy/Proxy.sol";


/**
 * @title SimpleUpgradableProxy
 * @dev Proxy which forwards function calls to a delegate contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract SimpleUpgradableProxy {

    address public delegate;
    address private owner = msg.sender;

    fallback() external {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), delegate.slot, 0, calldatasize(), 0, 0)

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

    function upgradeDelegate(address payable _newDelegateAddress) external {
        require(msg.sender == owner);
        delegate = _newDelegateAddress;
    }

    receive() payable external {
        // You should not send ETH to this proxy contract.
    }
}
