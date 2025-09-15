// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

interface ISafeVault{

    event ReceiveERC721(address operator, uint256 id, address from, bytes data);
    event Receive1155(address operator, uint256 id, uint256 value, address from, bytes data);
    event BatchReceive1155(address operator, uint256[] ids, uint256[] values, address from, bytes data);

}