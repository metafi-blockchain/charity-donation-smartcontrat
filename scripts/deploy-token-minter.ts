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
  contracts: {
    tokenMinter: ContractInfo;
  };
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

import type { TokenMinter } from "../typechain-types";

async function main(): Promise<void> {
  console.log("🚀 Starting Token Minter deployment...\n");

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

  // Deploy VND Token
  console.log("🪙 Deploying Token Minter...");

  const TokenMinterFactory = await ethers.getContractFactory("TokenMinter");
  const tokenMinter: TokenMinter = await TokenMinterFactory.deploy();

  await tokenMinter.waitForDeployment();
  const tokenMinterAddress = await tokenMinter.getAddress();

  console.log("✅ Token  Minter deployed to:", tokenMinterAddress);
  console.log("");

  // Setup admin
  await tokenMinter.setupAdmins([deployer.address], [true]);

  // Save deployment info
  const deploymentInfo: DeploymentInfo = {
    network: network.name,
    chainId: network.chainId.toString(),
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    contracts: {
      tokenMinter: {
        name: "TokenMinter",
        address: tokenMinterAddress,
        constructorArgs: [],
      },
    },
  };

  // Create deployments directory
  const deploymentsDir = path.join(__dirname, "../deployments");
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir, { recursive: true });
  }

  // Save to file
  const deploymentFile = path.join(
    deploymentsDir,
    `${network.name}-${network.chainId}-token-minter.json`
  );
  fs.writeFileSync(deploymentFile, JSON.stringify(deploymentInfo, null, 2));

  console.log("💾 Deployment info saved to:", deploymentFile);
  console.log("");

  console.log("🎉 VND Token deployment completed successfully!");
  console.log("");
  console.log("📋 Summary:");
  console.log("- Token Minter:", tokenMinterAddress);
  console.log("- Owner:", deployer.address);
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
