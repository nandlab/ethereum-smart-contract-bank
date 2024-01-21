// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./SimpleUpgradableProxy.sol";
import "./SecureBankStorageInterface.sol";


/**
 * @title SecureBankStorage
 * @dev Storage for the bank
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract SecureBankStorage is SecureBankStorageInterface {
    SimpleUpgradableProxy private bankProxy;
    
    mapping (address => uint) private balances;

    constructor(SimpleUpgradableProxy _bankProxy) {
        bankProxy = _bankProxy;
    }

    // This modifier ensures that only the latest bank implementation (with the latest security patches) can access a function
    modifier onlyLatestVersion() {
        // This contract gets the address of the latest bank implementation from the proxy
        require(msg.sender == bankProxy.delegate());
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
