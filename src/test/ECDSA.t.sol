import "ds-test/test.sol";
import "forge-std/stdlib.sol";
import "forge-std/Vm.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract ECDSATest is DSTest, stdCheats {
    using ECDSA for bytes32;
    bytes32 _hash;
    bytes _sig;

    function setUp() public {
        _hash = keccak256("Signed by Alice");
        (uint8 v, bytes32 r, bytes32 s) = sign(
            0x18ef5d5e78aa58a63503bcb48a563de61ffe7665d73ee22b4ab66ef15248be5a,
            _hash
        );
        _sig = abi.encodePacked(r, s, v);
    }

    function testSign() public {
        address alice = address(0x9BEF5148fD530244a14830f4984f2B76BCa0dC58); //alice的公钥
        //address  bob = address(
        //    0x8Aa8b0D84cf523923A459a6974C9499581d1F93D
        //); //bob的公钥
        bytes32 hash = keccak256("Signed by Alice"); //信息hash值
        (uint8 v, bytes32 r, bytes32 s) = sign(
            0x18ef5d5e78aa58a63503bcb48a563de61ffe7665d73ee22b4ab66ef15248be5a,
            hash
        ); //使用的alice的私钥、hash进行签名
        bytes memory sig = abi.encodePacked(r, s, v);
        address signer = hash.recover(sig); //使用的ECDSA recover 函数得到签名地址
        //emit log_named_address("address", signer);
        /*assertEq(alice, signer);
        (uint8 v2, bytes32 r2, bytes32 s2) = sign(
            0x4e1518672e45fb2746ec5a217330ed24d815d44537da647e973c06d0b0069053,
            hash
        );
        bytes memory sig2 = abi.encodePacked(r2, s2, v2);
        address signer2 = hash.recover(sig2);
        emit log_named_address("address", signer2);
        assertEq(bob, signer2);*/
    }
}
