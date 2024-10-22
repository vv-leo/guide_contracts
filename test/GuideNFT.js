// 导入必要的库
const { expect } = require('chai');
const { ethers } = require('hardhat');

// 导入合约的ABI和字节码（如果需要）
// const GuideNFTArtifact = require('../artifacts/contracts/GuideNFT.sol/GuideNFT.json');

describe('GuideNFT Contract', () => {
    let guideNFT;
    let deployer;
    let seller;
    let buyer;
    let tokenId = 1;
    let price = 986003127345510971n; // 设置价格为1 wei

    beforeEach(async () => {
        // 部署合约并获取部署者的地址
        const GuideNFT = await ethers.getContractFactory('GuideNFT');
        guideNFT = await GuideNFT.deploy();
        // await guideNFT.deployed();

        [deployer,seller, buyer] = await ethers.getSigners();
    });

    it('should list an NFT', async () => {
        // 铸造并上架NFT
        await guideNFT.listNFT(tokenId, price);
        expect(await guideNFT.isMinted(tokenId)).to.be.true;
        expect(await guideNFT.isListed(tokenId)).to.be.true;
        expect(await guideNFT.ownerOf(tokenId)).to.equal(deployer.address);
        console.log(guideNFT._tokenInfos(tokenId));
    });

    it('should delist an NFT', async () => {
        // 先铸造并上架NFT
        await guideNFT.listNFT(tokenId, price);
        // 下架NFT
        await guideNFT.deListNFT(tokenId);
        expect(await guideNFT.isListed(tokenId)).to.be.false;
    });

    it('should buy an NFT', async () => {
        // 铸造并上架NFT
        await guideNFT.listNFT(tokenId, price);
        // 买家购买NFT
        await buyer.sendTransaction({ to: deployer.address, value: price }); // 确保买家有足够的资金
        await guideNFT.connect(buyer).buyNFT(tokenId, { value: price });
        expect(await guideNFT.ownerOf(tokenId)).to.equal(buyer.address);
        expect(await guideNFT.isListed(tokenId)).to.be.false;
        // 检查资金是否已转移到卖家账户
        expect(await ethers.provider.getBalance(deployer.address)).to.equal(price);
    });

    // 可以添加更多测试用例来测试合约的其他方面，如错误处理等。
});