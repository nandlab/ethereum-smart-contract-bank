// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "remix_tests.sol"; 
import "../contracts/BankInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


contract LegitimateBankCustomer is Ownable, ReentrancyGuard {
    BankInterface private bank;

    constructor(BankInterface _bank) payable Ownable(msg.sender) {
        bank = _bank;
    }

    receive() external payable {}

    function depositToBank() external onlyOwner nonReentrant {
        bank.deposit{value: address(this).balance}();
    }

    function withdrawFromBank() external onlyOwner nonReentrant {
        bank.withdrawAll();
    }
}
