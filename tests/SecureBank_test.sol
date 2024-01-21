// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Assert} from "remix_tests.sol"; 
import {SecureBank} from "../contracts/SecureBank.sol";
import {BankInterface} from "../contracts/BankInterface.sol";
import {SecureBankStorage} from "../contracts/SecureBankStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {console} from "hardhat/console.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";


contract SecureBankTest is Ownable, ReentrancyGuard {
    ERC1967Proxy private bankProxy;
    SecureBank private bank;
    SecureBankStorage private bankStorage;

    constructor() Ownable(msg.sender) {}

    receive() external payable {}

    function beforeAll() external onlyOwner nonReentrant {
        console.log("UpgradableBankTest owner: %s", owner());
        console.log("UpgradableBankTest address: %s", address(this));
        
        console.log("Deploying bank...");
        bank = new SecureBank();
        console.log("Bank address: %s", address(bank));
        
        console.log("Deploying bank proxy...");
        bankProxy = new ERC1967Proxy(address(bank), abi.encodeWithSignature("initialize()"));
        console.log("Bank proxy address: %s", address(bankProxy));
        
        console.log("Deploying bank storage...");
        bankStorage = new SecureBankStorage(address(bankProxy));
        console.log("Bank storage address: %s", address(bankStorage));

        console.log("Configuring bank to use the bank storage...");
        SecureBank(payable(address(bankProxy))).setBankStorage(bankStorage);
        console.log("Done.");

        console.log("Initialization complete");
    }

    ///#value: 1000000000
    function testBank() external payable onlyOwner nonReentrant {
        uint value = 1000000000;
        Assert.equal(msg.value, value, "Different msg.value expected");
        uint startBalance = address(this).balance;
        BankInterface proxiedBank = BankInterface(payable(address(bankProxy)));

        console.log("Depositing money to bank...");
        proxiedBank.deposit{value: value}();
        console.log("Done.");
        Assert.equal(address(this).balance, startBalance - value, "Different balance expected");
        Assert.equal(address(bankProxy).balance, 0, "Bank proxy should have no balance");
        Assert.equal(address(bank).balance, 0, "Bank should have no balance");
        Assert.equal(address(bankStorage).balance, value, "Bank storage should have the balance");

        console.log("Withdrawing money from bank...");
        proxiedBank.withdrawAll();
        console.log("Done.");
        Assert.equal(address(this).balance, startBalance, "Test contract should have his money back");
        Assert.equal(address(bankProxy).balance, 0, "Bank proxy should have no balance");
        Assert.equal(address(bank).balance, 0, "Bank should have no balance");
        Assert.equal(address(bankStorage).balance, 0, "Bank storage should have no balance now");

        console.log("Returning money back to the test owner...");
        (bool success,) = owner().call{value: address(this).balance}("");
        require(success);
        console.log("Done.");
    }
}
