// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "ds-test/test.sol";

contract SimpleMultiSig {
    using ECDSA for bytes32;
    address public owner;
    address[5] public operators;

    constructor(address[] memory _operators) public payable {
        owner = msg.sender;
        require(_operators.length <= 5, "Too many operators");
        for (uint8 i = 0; i < _operators.length; i++) {
            operators[i] = _operators[i];
        }
    }

    function getTxHash(address to, uint256 _amount)
        public
        view
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(to, _amount));
    }

    function transfer(
        address _to,
        uint256 _amount,
        bytes[] memory sigs
    ) external {
        bytes32 txHash = getTxHash(_to, _amount);

        require(_checkSigs(txHash, sigs, 2), "Only operators can transfer");
        (bool sender, ) = _to.call{value: _amount}("");
        require(sender, "sender failed");
    }

    function _findOpt(address sigaddr) private view returns (bool) {
        for (uint8 i = 0; i < operators.length; i++) {
            //emit log_named_address("operators", operators[i]);
            if (operators[i] != address(0x0)) {
                if (operators[i] == sigaddr) {
                    //emit log_named_address("find", operators[i]);
                    return true;
                }
            } else {
                break;
            }
        }
        return false;
    }

    function _checkSigs(
        bytes32 txhash,
        bytes[] memory sigs,
        uint8 numSigs
    ) private view returns (bool) {
        uint8 c = 0;
        //emit log_named_uint("sigs len", sigs.length);
        for (uint8 i = 0; i < sigs.length; i++) {
            //emit log_named_bytes("txHash", txHash);
            if (!_findOpt(txhash.recover(sigs[i]))) {
                return false;
            }
            c++;
        }
        //emit log_named_uint("c", c);
        if (c > numSigs) {
            return true;
        } else {
            return false;
        }
    }
}
