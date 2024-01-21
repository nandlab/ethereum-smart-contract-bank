// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./BankInterface.sol";
import "./SecureBankStorage.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SecureBank
 * @dev Bank implementation immune to reentrancy attack
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract SecureBank is BankInterface, ReentrancyGuard {
    SecureBankStorage private bankStorage;

    constructor(address payable _bankStorage) {
        bankStorage = SecureBankStorage(_bankStorage);
    }

    function deposit() external override payable nonReentrant {
        (bool success,) = address(bankStorage).call{value: msg.value}("");
        require(success);
        uint balance = bankStorage.getBalance(msg.sender);
        bankStorage.setBalance(msg.sender, balance + msg.value);
    }

    receive() external payable {}

    function withdrawAll() external override nonReentrant {
        uint amount = bankStorage.getBalance(msg.sender);
        bankStorage.setBalance(msg.sender, 0);
        bankStorage.withdrawEther(amount);
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
    }
}
