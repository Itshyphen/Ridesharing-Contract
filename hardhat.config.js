require("@nomiclabs/hardhat-waffle");

// The next line is part of the sample project, you don't need it in your
// project. It imports a Hardhat task definition, that can be used for
// testing the frontend.

const PRIVATE_KEY =
  process.env.RINKEBY_PRIVATE_KEY ||
  process.env.PRIVATE_KEY ||
  "8fb7b2b7c68ebfb9b77feba8e6d5b2e4287cdc8cfdfd666e36c88c66f8495718";

// If you are using MetaMask, be sure to change the chainId to 1337
module.exports = {
  solidity: "0.8.4",
  networks: {
    hardhat: {
      chainId: 31337
    },
    rinkeby: {
      url:
        process.env.RINKEBY_URL ||
        "https://eth-rinkeby.alchemyapi.io/v2/duxZIp3vDkpO9wRSnHpbmIgfbLn9gXsm",
      accounts: [`${PRIVATE_KEY}`],
    },
    kovan: {
      url: process.env.KOVAN_URL || "",
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: "SQ1A8NSSS7U1KS56JXF1P2WW4FIHA6E98Z",
  },
};