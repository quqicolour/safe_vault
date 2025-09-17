// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

interface ISafeVault{

    event ReceiveERC721(address operator, uint256 id, address from, bytes data);
    event Receive1155(address operator, uint256 id, uint256 value, address from, bytes data);
    event BatchReceive1155(address operator, uint256[] ids, uint256[] values, address from, bytes data);

    event UpdateTokenLimit(address token, uint32 newRateLimit);
    event UpdateLock(bool newState);

    event TouchVault(uint64 indexed id, address toucher, bytes data);
    event TransferETH(
        uint64 indexed id, 
        address toucher, 
        address[] receivers, 
        uint256[] ethAmounts
    );
    event TranferERC20(
        uint64 indexed id, 
        address toucher, 
        address[] erc20Token,
        address[] receivers, 
        uint256[] tokenAmounts
    );
    event TransferERC721(
        uint64 indexed id, 
        address toucher, 
        address[] erc721Token,
        uint256[] ids, 
        address[] receiver
    );

}