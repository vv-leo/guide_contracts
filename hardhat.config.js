require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: "0.8.27",
    networks: {
        // hardhat: {
        //   // 可根据需要配置一些本地链的参数，比如挖矿速度等
        //   mining: {
        //     auto: true,
        //     interval: [500, 1000],
        //   },
        //   accounts: 10, // 生成 10 个测试账户
        // },
        local: {
            url: "http://127.0.0.1:8545",
            chainId: 31337,
        },
        sepolia: {
            url: `https://sepolia.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
            accounts: [process.env.WALLET_PRIVATE_KEY]
        }
    },
};
