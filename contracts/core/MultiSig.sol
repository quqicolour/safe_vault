// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.25;

abstract contract MultiSig {

    uint16 public threshold;
    uint16 public signerNumber;
    
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

    error NonSigner(address);
    error AlreadySigner(address);

    event AddSigner(address newSigner);
    event DelSigner(address oldSigner);
    event ChangeThreshold(uint16 olderThreshold, uint16 newThreshold);

    function _deleteSigner(address oldSigner) internal virtual {
        if(signer[oldSigner]){
            delete signer[oldSigner];
            signerNumber--;
            emit DelSigner(oldSigner);
        }else{
            revert NonSigner(oldSigner);
        }
    }

    function _addSigner(address newSigner) internal virtual {
        if(signer[newSigner]){
            signer[newSigner] = true;
            signerNumber++;
            emit AddSigner(newSigner);
        }else{
            revert AlreadySigner(newSigner);
        }
    }

    function _setThreshold(uint16 newThreshold) internal virtual {
        uint16 olderThreshold = threshold;
        threshold = newThreshold;
        emit ChangeThreshold(olderThreshold, newThreshold);
    }

    function _vote() internal virtual {

    }
}