import type { HardhatUserConfig, NetworkUserConfig } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-abi-exporter";
import "dotenv/config";

const bscTestnet: NetworkUserConfig = {
  url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
  chainId: 97,
  accounts: [
    "86cbe5362c5b397af09779e56820eb855086240d572ed38e12186072427a0d88",
  ],
};

const mtfMainnet: NetworkUserConfig = {
  url: "https://mft-chain.metafi.gg/rpc",
  chainId: 90048,
  accounts: [
    "86cbe5362c5b397af09779e56820eb855086240d572ed38e12186072427a0d88",
  ],
};

const mtfTestnet: NetworkUserConfig = {
  url: "http://13.229.154.89:9650/ext/bc/xwW6cSPYXjZqbbmgjdxzADhsLdTL9nH5XSeSAGRXksgVWtNNn/rpc",
  // url: "https://nodes-prod.18.182.4.86.sslip.io/ext/bc/xwW6cSPYXjZqbbmgjdxzADhsLdTL9nH5XSeSAGRXksgVWtNNn/rpc",
  chainId: 482611111,
  accounts: [
    "0x0069a05b68119ddf6bea76f430fbf2e468e9541d272966ace8628a6ee8874daf",
  ],
};

const avalTestnet: NetworkUserConfig = {
  url: "https://avalanche-fuji-c-chain-rpc.publicnode.com",
  chainId: 43113,
  accounts: [
    "86cbe5362c5b397af09779e56820eb855086240d572ed38e12186072427a0d88",
  ],
};

const bscMainnet: NetworkUserConfig = {
  url: "https://bsc-dataseed.binance.org/",
  chainId: 56,
  accounts: [
    "86cbe5362c5b397af09779e56820eb855086240d572ed38e12186072427a0d88",
  ],
};

const avalMainnet: NetworkUserConfig = {
  url: "https://avalanche.api.onfinality.io/public/ext/bc/C/rpc",
  chainId: 43114,
  accounts: [""],
};

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  etherscan: {
    apiKey: {
      snowtrace: "GIZ1V79NH9J1E659CXFWHNNSKYGAFK8Q3W", // apiKey is not required, just set a placeholder
      avalanche: "GIZ1V79NH9J1E659CXFWHNNSKYGAFK8Q3W",
      "metafi-chain": "empty",
    },
    customChains: [
      {
        network: "snowtrace",
        chainId: 43113,
        urls: {
          apiURL:
            "https://api.routescan.io/v2/network/testnet/evm/43113/etherscan",
          browserURL: "https://avalanche.testnet.localhost:8080",
        },
      },
      {
        network: "metafi-chain",
        chainId: 90048,
        urls: {
          apiURL: "https://mft-chain.metafi.gg/api",
          browserURL: "https://mft-chain.metafi.gg",
        },
      },
    ],
  },
  networks: {
    hardhat: {},
    bscTestnet: bscTestnet,
    bscMainnet: bscMainnet,
    avalTestnet: avalTestnet,
    avalMainnet: avalMainnet,
    "metafi-chain": mtfMainnet,
    mtfTestnet: mtfTestnet,
  },
  solidity: {
    compilers: [
      {
        version: "0.8.30",
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
          viaIR: true,
        },
      },
      {
        version: "0.6.10",
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
          viaIR: true,
        },
      },
    ],
  },
  sourcify: {
    enabled: true,
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  abiExporter: {
    path: "./data/abi",
    clear: true,
    flat: false,
  },
};

export default config;
