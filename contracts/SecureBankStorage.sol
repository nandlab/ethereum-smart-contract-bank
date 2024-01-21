// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {SecureBankStorageInterface} from "./SecureBankStorageInterface.sol";


/**
 * @title SecureBankStorage
 * @dev Storage for the bank
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract SecureBankStorage is SecureBankStorageInterface {
    address private bankProxy;
    
    mapping (address => uint) private balances;

    constructor(address _bankProxy) {
        require(_bankProxy != address(0));
        bankProxy = _bankProxy;
    }

    // Only accept function calls coming from the proxy (using the latest bank implementation respectively)
    modifier onlyLatestVersion() {
        require(msg.sender == bankProxy);
        _;
    }

    function setBalance(address _addr, uint balance) external override onlyLatestVersion {
        balances[_addr] = balance;
    }

    function getBalance(address _addr) external view override returns (uint) {
        return balances[_addr];
    }

    receive() external payable override {}

    function withdrawEther(uint _amount) external override onlyLatestVersion {
        (bool success,) = msg.sender.call{value: _amount}("");
        require(success);
    }
}
