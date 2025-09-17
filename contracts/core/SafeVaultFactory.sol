// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

import "./SafeVault.sol";

contract SafeVaultFactory {
    
    uint256 public vaultId;

    mapping(uint256 => address) public idToVault;

    event Create(address newVault, address creator);
    
    function createSafeVault(
        address owner_,
        address manager_,
        address[] memory signers_, 
        uint16 threshold_
    ) external {
        address newSafeVault = address(
            new SafeVault{
                salt: keccak256(abi.encodePacked(vaultId, block.timestamp, block.chainid))
            }(owner_, manager_, signers_, threshold_)
        );
        idToVault[vaultId] = newSafeVault;
        vaultId++;
        emit Create(newSafeVault, msg.sender);
        require(newSafeVault != address(0));
    }
}