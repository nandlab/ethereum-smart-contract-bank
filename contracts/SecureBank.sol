// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./BankInterface.sol";
import "./SecureBankStorageInterface.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SecureBank
 * @dev Bank implementation immune to reentrancy attack
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract SecureBank is BankInterface, ReentrancyGuard {
    SecureBankStorageInterface private bankStorage;

    constructor(SecureBankStorageInterface _bankStorage) {
        bankStorage = _bankStorage;
    }

    function deposit() external override payable nonReentrant {
        uint balance = bankStorage.getBalance(msg.sender);
        bankStorage.setBalance(msg.sender, balance + msg.value);
        (bool success,) = address(bankStorage).call{value: msg.value}("");
        require(success);
    }

    receive() external payable {}

    /**
     * @dev withdrawAll implementation which is safe against reentrancy attacks
     * This implementation of the withdrawAll function has two protection mechanisms against reentrancy attacks:
     * * nonReentrant modifier to prevent reentrance completely
     * * Send the Ether amount to the user at the end of the function
     */
    function withdrawAll() external override nonReentrant {
        uint amount = bankStorage.getBalance(msg.sender);
        bankStorage.setBalance(msg.sender, 0);
        bankStorage.withdrawEther(amount);
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
    }
}
