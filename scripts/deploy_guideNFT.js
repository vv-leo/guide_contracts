const hre = require("hardhat");

async function main() {
    const MyNFT = await hre.ethers.getContractFactory("GuideNFT");
    const nftContract = await MyNFT.deploy();
    console.log("MyNFT deployed to:", nftContract.target);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });