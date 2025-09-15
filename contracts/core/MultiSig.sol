// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

abstract contract MultiSig is ReentrancyGuard {
    
    uint16 public threshold;
    uint16 public signerNumber;
    uint64 public proposalID;
    
    mapping(address => bool) public signer;

    constructor(address[] memory _signers, uint16 _threshold){
        threshold = _threshold;
        unchecked{
            for(uint256 i; i<_signers.length; i++){
                _addSigner(_signers[i]);
                signerNumber++;
            }
        }
    }

    struct ProposalInfo{
        uint16 yes;
        uint16 no;
        uint64 startTime;
        uint64 endTime;
        bytes data;
    }

    mapping(uint64 => ProposalInfo) public proposalInfo;

    mapping(address => mapping(uint64 => bool))public whetherVoted;

    error NonSigner(address);
    error AlreadySigner(address);

    event AddSigner(address newSigner);
    event DelSigner(address oldSigner);
    event ChangeThreshold(uint16 olderThreshold, uint16 newThreshold);
    event NewProposal(uint256 id, uint64 endTime, bytes data);

    modifier onlySigner() {
        _checkSigner();
        _;
    }
    
    modifier onlyMultiSigPass(uint64 _proposalID) {
        require(checkThreshold(_proposalID), "The proposal is invalid.");
        _;
    }

    function _addSigner(address newSigner) internal {
        if(signer[newSigner]){
            signer[newSigner] = true;
            signerNumber++;
            emit AddSigner(newSigner);
        }else{
            revert AlreadySigner(newSigner);
        }
    }

    function _deleteSigner(address oldSigner) internal {
        if(signer[oldSigner]){
            delete signer[oldSigner];
            signerNumber--;
            emit DelSigner(oldSigner);
        }else{
            revert NonSigner(oldSigner);
        }
    }

    function changeSigner(
        uint64 _proposalID, 
        address _signer,
        bool state
    ) external onlySigner onlyMultiSigPass(_proposalID) {
        if(state){
            _addSigner(_signer);
        }else {
            _deleteSigner(_signer);
        }
    }

    function setThreshold(uint64 _proposalID, uint16 newThreshold) 
        external 
        onlySigner 
        onlyMultiSigPass(_proposalID) 
    {
        uint16 olderThreshold = threshold;
        threshold = newThreshold;
        emit ChangeThreshold(olderThreshold, newThreshold);
    }

    function createProposal(uint64 _endTime, bytes memory data) 
        external 
        onlySigner 
    {
        proposalInfo[proposalID].startTime = uint64(block.timestamp);
        proposalInfo[proposalID].endTime = _endTime;
        proposalInfo[proposalID].data = data;
        emit NewProposal(proposalID, _endTime, data);
        proposalID++;
    }

    function vote(uint64 _proposalID, bool decision) external onlySigner nonReentrant {
        uint64 endTime = proposalInfo[_proposalID].endTime;
        require(endTime !=0 && block.timestamp < endTime, "Invalid proposalID");
        require(whetherVoted[msg.sender][_proposalID] == false, "Already voted");
        whetherVoted[msg.sender][_proposalID] = true;
        if(decision){
            proposalInfo[_proposalID].yes++;
        }else{
            proposalInfo[_proposalID].no++;
        }
    }

    function checkThreshold(uint64 _proposalID) public view returns (bool state) {
        uint16 yes = proposalInfo[_proposalID].yes;
        uint16 no = proposalInfo[_proposalID].no;
        uint64 endTime = proposalInfo[_proposalID].endTime;
        if(
            block.timestamp >= endTime && 
            yes >= threshold && 
            yes > no && 
            endTime!=0
        ){
            state = true;
        }
    }

    function _checkSigner() internal view {
        require(signer[msg.sender], "Not the signer");
    }

    function stringToBytes(string calldata stringData) external view returns (bytes memory bytesData) {
        bytesData = bytes(stringData);
    }

    function bytesToString(bytes calldata bytesData) external view returns (string memory stringData) {
        stringData = string(bytesData);
    }
}