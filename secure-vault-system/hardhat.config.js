require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: false,
        runs: 200,
      },
    },
  },

networks: {
  localhost: {
    url: "http://blockchain:8545",
    chainId: 1337,
  },
},
};