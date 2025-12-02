// types/deployment.ts
export interface DeploymentConfig {
  tokenName: string;
  tokenSymbol: string;
  initialOwner: string;
  trustedForwarder: string;
}

export interface ContractInfo {
  name: string;
  address: string;
  constructorArgs: any[];
}

export interface DeploymentInfo {
  network: string;
  chainId: string;
  deployer: string;
  timestamp: string;
  gasUsed: {
    forwarder: string;
    token: string;
    total: string;
  };
  contracts: {
    vnd: ContractInfo;
    forwarder: ContractInfo;
  };
  config: DeploymentConfig;
}

export interface NetworkRpcUrls {
  [key: string]: string;
}

export interface SupportedInterface {
  name: string;
  id: string;
}

// scripts/deploy.ts
import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

import type { VND } from "../typechain-types";

async function main(): Promise<void> {
  console.log("🚀 Starting VND Token deployment...\n");

  // Get network and deployer info
  const network = await ethers.provider.getNetwork();
  const [deployer] = await ethers.getSigners();

  console.log("📋 Deployment Details:");
  console.log("Network:", network.name);
  console.log("Chain ID:", network.chainId.toString());
  console.log("Deployer:", deployer.address);
  console.log(
    "Balance:",
    ethers.formatEther(await ethers.provider.getBalance(deployer.address)),
    "ETH"
  );
  console.log("");

  // Configuration
  const config: DeploymentConfig = {
    tokenName: process.env.TOKEN_NAME || "VND Token",
    tokenSymbol: process.env.TOKEN_SYMBOL || "VND",
    initialOwner: process.env.INITIAL_OWNER || deployer.address,
    trustedForwarder:
      // process.env.TRUSTED_FORWARDER ||
      "0x1589Fb115438C7C95D00306C68F9986674b477BD",
  };

  console.log("⚙️  Configuration:");
  console.log("Token Name:", config.tokenName);
  console.log("Token Symbol:", config.tokenSymbol);
  console.log("Initial Owner:", config.initialOwner);
  console.log("Trusted Forwarder:", config.trustedForwarder);
  console.log("");

  // Deploy VND Token
  console.log("🪙 Deploying VND Token...");

  const VNDFactory = await ethers.getContractFactory("VND");
  const vnd: VND = await VNDFactory.deploy(
    config.tokenName,
    config.tokenSymbol,
    config.trustedForwarder,
    config.initialOwner
  );

  await vnd.waitForDeployment();
  const vndAddress = await vnd.getAddress();

  console.log("✅ VND Token deployed to:", vndAddress);
  console.log("");

  // Verify deployment
  console.log("🔍 Verifying deployment...");
  const tokenInfo = await vnd.getTokenInfo();

  console.log("Token Name:", tokenInfo.tokenName);
  console.log("Token Symbol:", tokenInfo.tokenSymbol);
  console.log("Token Decimals:", tokenInfo.tokenDecimals.toString());
  console.log("Total Supply:", ethers.formatEther(tokenInfo.tokenTotalSupply));
  console.log("Owner:", tokenInfo.tokenOwner);
  console.log("Trusted Forwarder:", tokenInfo.tokenTrustedForwarder);
  console.log("Is Owner a Minter:", await vnd.isMinter(tokenInfo.tokenOwner));
  console.log("");

  // Save deployment info
  const deploymentInfo: DeploymentInfo = {
    network: network.name,
    chainId: network.chainId.toString(),
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    gasUsed: {
      forwarder:
        config.trustedForwarder === "0x0000000000000000000000000000000000000000"
          ? "~500k"
          : "0",
      token: "~2.5M",
      total: "~3M",
    },
    contracts: {
      vnd: {
        name: "VND",
        address: vndAddress,
        constructorArgs: [
          config.tokenName,
          config.tokenSymbol,
          config.trustedForwarder,
          config.initialOwner,
        ],
      },
      forwarder: {
        name: "MetafiForwarder",
        address: config.trustedForwarder,
        constructorArgs:
          config.trustedForwarder ===
          "0x0000000000000000000000000000000000000000"
            ? []
            : [],
      },
    },
    config: config,
  };

  // Create deployments directory
  const deploymentsDir = path.join(__dirname, "../deployments");
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir, { recursive: true });
  }

  // Save to file
  const deploymentFile = path.join(
    deploymentsDir,
    `${network.name}-${network.chainId}-vnd.json`
  );
  fs.writeFileSync(deploymentFile, JSON.stringify(deploymentInfo, null, 2));

  console.log("💾 Deployment info saved to:", deploymentFile);
  console.log("");

  // Generate environment variables for NestJS
  console.log("🔧 Environment Variables for NestJS API:");
  console.log(`TOKEN_CONTRACT_ADDRESS=${vndAddress}`);
  console.log(`FORWARDER_CONTRACT_ADDRESS=${config.trustedForwarder}`);
  console.log("PRIVATE_KEY=your_relayer_private_key");
  console.log("");

  // Display interface support
  console.log("🔍 Supported Interfaces:");
  const interfaces: SupportedInterface[] = [
    { name: "IERC165", id: "0x01ffc9a7" },
    { name: "IERC20", id: "0x36372b07" },
    { name: "IERC20Metadata", id: "0xa219a025" },
    { name: "IERC20Permit", id: "0x9d8ff7da" },
  ];

  console.log("🎉 VND Token deployment completed successfully!");
  console.log("");
  console.log("📋 Summary:");
  console.log("- VND Token:", vndAddress);
  console.log("- Forwarder:", config.trustedForwarder);
  console.log("- Owner:", config.initialOwner);
  console.log("- Network:", network.name);
  console.log("- Chain ID:", network.chainId.toString());
}

// Handle deployment errors
main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
