import type { HardhatUserConfig, NetworkUserConfig } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-abi-exporter";
import "dotenv/config";

const bscTestnet: NetworkUserConfig = {
  url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
  chainId: 97,
  accounts: [
    "a7006c66b45d234ffd75a4d7cb86ca5b71472a524d90735a2ec411ef427eff26",
  ],
};

const avalTestnet: NetworkUserConfig = {
  url: "https://ava-testnet.public.blastapi.io/ext/bc/C/rpc",
  chainId: 43113,
  accounts: [
    "86cbe5362c5b397af09779e56820eb855086240d572ed38e12186072427a0d88",
  ],
};

const bscMainnet: NetworkUserConfig = {
  url: "https://bsc-dataseed.binance.org/",
  chainId: 56,
  accounts: [
    "4d842aee0df0e349898e51e7e827dca80f8baf57a87092d82b7991193e3474cf",
  ],
};

const avalMainnet: NetworkUserConfig = {
  url: "https://avalanche.api.onfinality.io/public/ext/bc/C/rpc",
  chainId: 43114,
  accounts: [
    "4d842aee0df0e349898e51e7e827dca80f8baf57a87092d82b7991193e3474cf",
  ],
};

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  etherscan: {
    apiKey: {
      snowtrace: "GIZ1V79NH9J1E659CXFWHNNSKYGAFK8Q3W", // apiKey is not required, just set a placeholder
      avalanche: "GIZ1V79NH9J1E659CXFWHNNSKYGAFK8Q3W",
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
    ],
  },
  networks: {
    hardhat: {},
    bscTestnet: bscTestnet,
    bscMainnet: bscMainnet,
    avalTestnet: avalTestnet,
    avalMainnet: avalMainnet,
  },
  solidity: {
    compilers: [
      {
        version: "0.8.20",
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
