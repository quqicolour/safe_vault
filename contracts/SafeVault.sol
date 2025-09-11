// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

contract SafeVault {

    uint64 public freezingTime;
    uint64 public delayTime;

    receive() payable external {}

    function callVault(bytes calldata data) external {

    }

    function transferToken(
        address tokenAddress,
        address receiver, 
        uint256 amount
    ) external {

    }
}