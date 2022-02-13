# ECDSA使用，以及实现多签 （一）

ECDSA在前面的文章已经提到，[尝试爆破NFT奖励时间限制 （二）](https://learnblockchain.cn/article/3518)
这方面的原理，以及实现我就不讨论了，文章比较多，程序员嘛，除了自己写的代码，就是关注接口了，所以会使用，就OK了。

## 文档
我这里使用的[openzeppelin](https://docs.openzeppelin.com/contracts/4.x/api/utils#ECDSA)的实现，大家可以看看这里的文档。

```
FUNCTIONS
    tryRecover(hash, signature)
    recover(hash, signature)
    tryRecover(hash, r, vs)
    recover(hash, r, vs)
    tryRecover(hash, v, r, s)
    recover(hash, v, r, s)
    toEthSignedMessageHash(hash)
    toEthSignedMessageHash(s)
    toTypedDataHash(domainSeparator, structHash)
```
加密中比较重要的，私钥，公钥，信息

### 签名：
1. 钱包用私钥，
2. 信息 hash，
3. 生成签名。

### 验证签名：
1. 信息生成公钥hash
2. 信息 hash recover 签名，得到签名的公钥地址
3. 比较公钥地址一致，说明是这个地址签名的

## 代码
直接来个测试用例，说明这个过程，里面的私钥都**来自Ganache公开的私钥**
，测试使用环境用的forge,不会用forge，看这里[forge 入门](https://learnblockchain.cn/article/3502)
```
    function testSign() public {
        address alice = address(0x9BEF5148fD530244a14830f4984f2B76BCa0dC58); //alice的公钥
        address bob = address(0x8Aa8b0D84cf523923A459a6974C9499581d1F93D); //bob的公钥
        bytes32 hash = keccak256("Signed by Alice"); //信息hash值
        (uint8 v, bytes32 r, bytes32 s) = sign(
            0x18ef5d5e78aa58a63503bcb48a563de61ffe7665d73ee22b4ab66ef15248be5a,
            hash
        ); //使用的alice的私钥、hash进行签名
        bytes memory sig = abi.encodePacked(r, s, v);
        address signer = hash.recover(sig); //使用的ECDSA recover 函数得到签名地址
        emit log_named_address("address", signer);
        assertEq(alice, signer);
        (uint8 v2, bytes32 r2, bytes32 s2) = sign(
            0x4e1518672e45fb2746ec5a217330ed24d815d44537da647e973c06d0b0069053,
            hash
        );
        bytes memory sig2 = abi.encodePacked(r2, s2, v2);
        address signer2 = hash.recover(sig2);
        emit log_named_address("address", signer2);
        assertEq(bob, signer2);
    }
```
就这样，做多签的基础就有了，下一篇就讲讲怎么做到多签名确认，才能转账。
上面的代码对，[forge-std](https://github.com/brockelmore/forge-std)加了一个小函数。
更详细的，看我github上的仓库。

