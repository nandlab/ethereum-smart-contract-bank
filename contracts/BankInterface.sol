// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title BankInterface
 * @dev Interface for a bank
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
interface BankInterface {
    function deposit() external payable;

    function withdrawAll() external;
}
