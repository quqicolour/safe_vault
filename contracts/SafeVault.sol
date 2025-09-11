// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract SafeVault is ERC165, IERC721Receiver, IERC1155Receiver {
    using SafeERC20 for IERC20;

    address public owner;
    address public manager;

    uint64 public freezingTime;
    uint64 public delayTime;

    mapping(address => bool) public signer;

    constructor(address[] memory signers) {
        unchecked {
            for (uint256 i; i < signers.length; i++) {
                signer[signers[i]] = true;
            }
        }
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

    modifier onlySigner() {
        _checkSigner();
        _;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC721Receiver).interfaceId ||
            type(IERC1155Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function callVault(bytes calldata data) external {}

    function transferETH(
        address[] calldata receiver,
        uint256[] calldata amount
    ) external {
        unchecked{
            for(uint256 i; i<receiver.length; i++){
                (bool success, ) = receiver.call{value: amount}("");
                require(success);
            }
        }
    }

    function transferERC20(
        address[] calldata erc20Token,
        address[] calldata receiver,
        uint256[] calldata amount
    ) external {}

    function transferERC721(
        address[] calldata erc721Token,
        uint256[] calldata ids,
        address[] calldata receiver
    ) external {}

    function transferERC1155(
        address[] calldata erc1155Token,
        uint256[] calldata ids,
        address[] calldata receiver
    ) external {}

    function emergency() external {}

    function _checkOwner() private view {
        require(msg.sender == owner, "Non owner");
    }

    function _checkManager() private view {
        require(msg.sender == manager, "Non manager");
    }

    function _checkSigner() private view {
        require(signer[msg.sender], "Not the signer!");
    }
}
