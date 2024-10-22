const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    const MyContract = await ethers.getContractFactory("MyContract");
    const myContract = await MyContract.deploy();
    console.log(JSON.stringify(myContract));
    console.log("Contract deployed to address:", myContract.target);
}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });