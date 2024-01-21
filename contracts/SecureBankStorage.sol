// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./SimpleUpgradableProxy.sol";

/**
 * @title SecureBankStorage
 * @dev Storage for the bank
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract SecureBankStorage {
    address private owner;
    SimpleUpgradableProxy private bankProxy;
    
    mapping (address => uint) private balances;

    constructor(address payable ) {
        owner = msg.sender;
    }

    modifier onlyLatestVersion() {
        require(msg.sender == bankProxy.delegate());
        _;
    }

    function setBalance(address _addr, uint balance) external onlyLatestVersion {
        balances[_addr] = balance;
    }

    function getBalance(address _addr) external view returns (uint) {
        return balances[_addr];
    }

    receive() external payable {}

    function withdrawEther(uint _amount) external onlyLatestVersion {
        (bool success,) = msg.sender.call{value: _amount}("");
        require(success);
    }
}
