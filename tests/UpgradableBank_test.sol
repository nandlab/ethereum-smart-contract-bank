// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "remix_tests.sol"; 
import "../contracts/SimpleUpgradableProxy.sol";
import "../contracts/SecureBank.sol";
import "../contracts/SecureBankStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "hardhat/console.sol";


contract UpgradableBankTest is Ownable, ReentrancyGuard {
    SimpleUpgradableProxy private bankProxy;
    SecureBank private bank;
    SecureBankStorage private bankStorage;

    constructor() Ownable(msg.sender) {}

    receive() external payable {}

    function beforeAll() external onlyOwner nonReentrant {
        console.log("UpgradableBankTest owner address: %s", owner());
        console.log("UpgradableBankTest address: %s", address(this));
        
        console.log("Deploying bank proxy...");
        bankProxy = new SimpleUpgradableProxy();
        console.log("Bank proxy address: %s", address(bankProxy));
        Assert.equal(bankProxy.delegate(), address(0), "bankProxy delegate should not be set yet");
        
        console.log("Deploying bank storage...");
        bankStorage = new SecureBankStorage(bankProxy);
        console.log("Bank storage address: %s", address(bankStorage));
        
        console.log("Deploying bank...");
        bank = new SecureBank(bankStorage);
        console.log("Bank address: %s", address(bank));
        
        console.log("Setting bank proxy delegate...");
        bankProxy.upgradeDelegate(address(bank));
        Assert.equal(bankProxy.delegate(), address(bank), "bankProxy delegate should be the bank");
        console.log("Initialization complete");
    }

    ///#value: 1000000000
    function testBank() external payable onlyOwner nonReentrant {
        uint value = 1000000000;
        Assert.equal(msg.value, value, "Different msg.value expected");
        uint startBalance = address(this).balance;

        console.log("Depositing money to bank...");
        (bool depositSuccess,) = address(bankProxy).call{value: value}(abi.encodeWithSignature("deposit()"));
        Assert.ok(depositSuccess, "Deposit failed");
        console.log("Done.");
        Assert.equal(address(this).balance, startBalance - value, "Different balance expected");
        Assert.equal(address(bankProxy).balance, 0, "Bank proxy should habe no balance");
        Assert.equal(address(bank).balance, 0, "Bank should have no balance");
        Assert.equal(address(bankStorage).balance, value, "Bank storage should have the balance");

        console.log("Withdrawing money from bank...");
        (bool withdrawSuccess,) = address(bankProxy).call(abi.encodeWithSignature("withdrawAll()"));
        Assert.ok(withdrawSuccess, "Withdraw failed");
        console.log("Done.");
        Assert.equal(address(this).balance, startBalance, "Test contract should have his money back");
        Assert.equal(address(bankProxy).balance, 0, "Bank proxy should habe no balance");
        Assert.equal(address(bank).balance, 0, "Bank should have no balance");
        Assert.equal(address(bankStorage).balance, value, "Bank storage should have no balance now");

        console.log("Returning money back to the test owner...");
        (bool success,) = owner().call{value: address(this).balance}("");
        require(success);
        console.log("Done.");
    }
}
