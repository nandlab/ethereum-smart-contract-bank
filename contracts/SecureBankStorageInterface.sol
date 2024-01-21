// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title SecureBankStorageInterface
 * @dev Storage interface for the bank
 * It stores all the persistent state of the bank, which is:
 * * Balance of each customer address
 * * Bank's Ether in the contract balance
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
interface SecureBankStorageInterface {
    function setBalance(address _addr, uint balance) external;

    function getBalance(address _addr) external view returns (uint);

    receive() external payable;

    function withdrawEther(uint _amount) external;
}
