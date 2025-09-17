// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

import "./MultiSig.sol";
import "../interfaces/ISafeVault.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract SafeVault is 
    ERC165, 
    MultiSig,
    ISafeVault, 
    IERC721Receiver, 
    IERC1155Receiver 
{
    using SafeERC20 for IERC20;

    uint256 public orderId;

    address public owner;
    uint64 public freezingTime;
    uint64 public delayTime;

    bool public lockState;

    enum Identity{people, whitelist, blacklist, manager}
    
    mapping(address => uint32) public tokenRateLimit;

    mapping(address => Identity) public userIdentity;

    constructor(
        address owner_,
        address manager_,
        address[] memory signers_, 
        uint16 threshold_
    ) MultiSig(signers_, threshold_) {
        owner = owner_;
        userIdentity[manager_] = Identity.manager;
    }

    receive() external payable {}

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    modifier onlyManager() {
        _checkManager();
        _;
    }

    modifier Lock() {
        require(lockState == false, "Locked");
        _;
    }

    function updateLock(bool state) external onlyManager {
        lockState = state;
        emit UpdateLock(state);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721Receiver).interfaceId ||
            interfaceId == type(IERC1155Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        emit ReceiveERC721(operator, tokenId, from, data);
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4){
        emit Receive1155(operator, id, value, from, data);
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4){
        emit BatchReceive1155(operator, ids, values, from, data);
        return this.onERC1155BatchReceived.selector;
    }

    function setTokenRateLimit(
        address token, 
        uint32 rateLimit
    ) external onlyManager {
        tokenRateLimit[token] = rateLimit;
        emit UpdateTokenLimit(token, rateLimit);
    }


    function callVault(
        uint64 _proposalID,
        address target, 
        bytes calldata data
    ) external Lock onlySigner onlyMultiSigPass(_proposalID) {
        (bool success, ) = target.call(data);
        require(success, "Call fail");
        emit TouchVault(_proposalID, msg.sender, data);
    }

    function transferETH(
        uint64 _proposalID,
        address[] calldata receiver,
        uint256[] calldata amount
    ) external Lock onlySigner onlyMultiSigPass(_proposalID) {
        unchecked{
            for(uint256 i; i<receiver.length; i++){
                (bool success, ) = receiver[i].call{value: amount[i]}("");
                require(success);
            }
        }
        emit TransferETH(_proposalID, msg.sender, receiver, amount);
    }

    function transferERC20(
        uint64 _proposalID,
        address[] calldata erc20Token,
        address[] calldata receiver,
        uint256[] calldata amount
    ) external Lock onlySigner onlyMultiSigPass(_proposalID) {
        unchecked{
            for(uint256 i; i< receiver.length; i++){
                IERC20(erc20Token[i]).safeTransfer(receiver[i], amount[i]);
            }
        }
        emit TranferERC20(_proposalID, msg.sender, erc20Token, receiver, amount);
    }

    function transferERC721(
        uint64 _proposalID,
        address[] calldata erc721Token,
        uint256[] calldata ids,
        address[] calldata receiver
    ) external Lock onlySigner onlyMultiSigPass(_proposalID) {
        unchecked{
            for(uint256 i; i<ids.length; i++){
                IERC721(erc721Token[i]).safeTransferFrom(address(this), receiver[i], ids[i]);
            }
        }
        emit TransferERC721(_proposalID, msg.sender, erc721Token, ids, receiver);
    }

    function transferERC1155(
        uint64 _proposalID,
        address erc1155Token,
        address receiver,
        uint256[] calldata ids,
        uint256[] calldata values
    ) external Lock onlySigner onlyMultiSigPass(_proposalID) {
        unchecked{
            for(uint256 i; i<ids.length; i++){
                IERC1155(erc1155Token).safeBatchTransferFrom(address(this), receiver, ids, values, "");
            }
        }
    }

    function emergency(
        uint64 _proposalID, 
        address target, 
        bytes calldata data
    ) external onlySigner onlyMultiSigPass(_proposalID) {
        lockState = true;
        (bool success, ) = target.call(data);
        require(success, "Call fail");
    }

    function _checkOwner() private view {
        require(msg.sender == owner, "Non owner");
    }

    function _checkManager() private view {
        require(userIdentity[msg.sender] == Identity.manager, "Non manager");
    }

    

}
