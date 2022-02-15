// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "forge-std/stdlib.sol";
import "forge-std/Vm.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../SimpleMultiSig.sol";

contract SimpleMultiSigTest is DSTest, stdCheats {
    using ECDSA for bytes32;
    SimpleMultiSig simpleMultiSig;

    function setUp() public {
        address[] memory opts = new address[](4);
        opts[0] = address(0x9BEF5148fD530244a14830f4984f2B76BCa0dC58);
        opts[1] = address(0x8Aa8b0D84cf523923A459a6974C9499581d1F93D);
        opts[2] = address(0x00D4F85f1D8333622c7F2e3E67c83224FAD9b6Bf);
        opts[3] = address(0xAC61E605E29a6a58005692d1324d8C3AB5F2c771);
        simpleMultiSig = new SimpleMultiSig(opts);
        hoax(address(simpleMultiSig), 5 ether);
    }

    function getSign(
        address to,
        uint256 _amount,
        uint256 pri
    ) public returns (bytes memory) {
        bytes32 txhash = keccak256(abi.encodePacked(to, _amount));
        (uint8 v, bytes32 r, bytes32 s) = sign(pri, txhash);
        bytes memory sign = abi.encodePacked(r, s, v);
        //emit log_named_uint("sign length", uint256(sign.length));
        return sign;
    }

    function testTransfer() public {
        bytes memory sign1 = getSign(
            address(0xAC61E605E29a6a58005692d1324d8C3AB5F2c771),
            1 ether,
            0x18ef5d5e78aa58a63503bcb48a563de61ffe7665d73ee22b4ab66ef15248be5a
        );
        bytes memory sign2 = getSign(
            address(0xAC61E605E29a6a58005692d1324d8C3AB5F2c771),
            1 ether,
            0x4e1518672e45fb2746ec5a217330ed24d815d44537da647e973c06d0b0069053
        );
        bytes memory sign3 = getSign(
            address(0xAC61E605E29a6a58005692d1324d8C3AB5F2c771),
            1 ether,
            0xae4c0e0111bcdb15e6c5d8873addadcd69b8c8dda3df7ac8c696bd4f02af40fd
        );
        bytes[] memory sigs = new bytes[](3);
        sigs[0] = sign1;
        sigs[1] = sign2;
        sigs[2] = sign3;
        emit log("start transfer");
        simpleMultiSig.transfer(
            address(0xAC61E605E29a6a58005692d1324d8C3AB5F2c771),
            1 ether,
            sigs
        );
        emit log_named_uint("end transfer", address(simpleMultiSig).balance);
    }

    function testTransfer2() public {
        bytes memory sign1 = getSign(
            address(0xAC61E605E29a6a58005692d1324d8C3AB5F2c771),
            1 ether,
            0x18ef5d5e78aa58a63503bcb48a563de61ffe7665d73ee22b4ab66ef15248be5a
        );
        bytes memory sign2 = getSign(
            address(0xAC61E605E29a6a58005692d1324d8C3AB5F2c771),
            1 ether,
            0xae4c0e0111bcdb15e6c5d8873addadcd69b8c8dda3df7ac8c696bd4f02af40fd
        );
        bytes memory sign3 = getSign(
            address(0xAC61E605E29a6a58005692d1324d8C3AB5F2c771),
            1 ether,
            0xae4c0e0111bcdb15e6c5d8873addadcd69b8c8dda3df7ac8c696bd4f02af40fd
        );
        bytes[] memory sigs = new bytes[](3);
        sigs[0] = sign1;
        sigs[1] = sign2;
        sigs[2] = sign3;
        emit log("start transfer");
        try
            simpleMultiSig.transfer(
                address(0xAC61E605E29a6a58005692d1324d8C3AB5F2c771),
                1 ether,
                sigs
            )
        {
            emit log_named_uint("transfer ok", address(simpleMultiSig).balance);
        } catch {}
        assertTrue(address(simpleMultiSig).balance == 5 ether);
        //emit log_named_uint("end transfer", address(simpleMultiSig).balance);
    }
}
