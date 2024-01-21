// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {BankInterface} from "./BankInterface.sol";
import {SecureBankStorageInterface} from "./SecureBankStorageInterface.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {console} from "hardhat/console.sol";


/**
 * @title SecureBank
 * @dev Bank implementation immune to reentrancy attack
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract SecureBank is BankInterface, Initializable, OwnableUpgradeable, UUPSUpgradeable, ReentrancyGuard {
    SecureBankStorageInterface private bankStorage;

    /**
     * @dev Initialize the SecureBank contract
     * bankStorage can be set either here or later with the setBankStorage function.
     * To set it later, just pass the zero address here.
     */
    function initialize(SecureBankStorageInterface _bankStorage) initializer external {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        bankStorage = _bankStorage;
    }

    function setBankStorage(SecureBankStorageInterface _bankStorage) external onlyOwner {
        require(address(bankStorage) == address(0), "Bank storage address is already set");
        require(address(_bankStorage) != address(0), "Bank storage address cannot be zero");
        bankStorage = _bankStorage;
    }

    constructor() {
        _disableInitializers();
    }

    modifier bankStorageSet {
        require(address(bankStorage) != address(0));
        _;
    }

    function deposit() external override payable bankStorageSet nonReentrant {
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
    function withdrawAll() external override bankStorageSet nonReentrant {
        uint amount = bankStorage.getBalance(msg.sender);
        bankStorage.setBalance(msg.sender, 0);
        bankStorage.withdrawEther(amount);
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
    }

    function _authorizeUpgrade(address newImplementation) internal view override onlyOwner {}
}
