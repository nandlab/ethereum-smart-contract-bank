// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./BankInterface.sol";


/**
 * @title VulnerableBank
 * @dev Same code as given in the task, except that it implements BankInterface
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract VulnerableBank is BankInterface {
    mapping (address => int) public balances;

    function deposit() public override payable {
        balances[msg.sender] += int(msg.value);
    }

    function withdrawAll() public override {
        int amount = balances[msg.sender];
        // If msg.sender is a smart contract, the following line
        // hands control to its receive() or fallback() function.
        (bool success, ) = msg.sender.call{value: uint(amount)}("");
        require(success);
        balances[msg.sender] -= amount;
    }
}
