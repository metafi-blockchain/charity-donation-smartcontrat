import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

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
    forwarder: ContractInfo;
  };
}

async function main() {
  // Get network and deployer info
  const network = await ethers.provider.getNetwork();
  const [deployer] = await ethers.getSigners();

  console.log("Starting deployment...");

  // Get signers
  const [admin] = await ethers.getSigners();

  console.log("Deploying with admin account:", admin.address);
  console.log(
    "Admin balance:",
    ethers.formatEther(await admin.provider.getBalance(admin.address)),
    "AVAL"
  );

  // Deploy MetafiForwarder
  console.log("\nDeploying MetafiForwarder...");
  const MetafiForwarder = await ethers.getContractFactory("MetafiForwarder");
  const forwarder = await MetafiForwarder.deploy();
  await forwarder.waitForDeployment(); // Updated for ethers v6

  console.log("MetafiForwarder deployed to:", await forwarder.getAddress());

  // Save deployment info
  const deploymentInfo: DeploymentInfo = {
    network: network.name,
    chainId: network.chainId.toString(),
    deployer: deployer.address,
    timestamp: new Date().toISOString(),

    contracts: {
      forwarder: {
        name: "MetafiForwarder",
        address: await forwarder.getAddress(),
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
    `${network.name}-${network.chainId}.json`
  );
  fs.writeFileSync(deploymentFile, JSON.stringify(deploymentInfo, null, 2));

  console.log("💾 Deployment info saved to:", deploymentFile);
  console.log("");
}

// Error handling
main()
  .then((addresses) => {
    console.log("\n" + "=".repeat(50));
    console.log("DEPLOYMENT SUMMARY");
    console.log("=".repeat(50));
    console.log(JSON.stringify(addresses, null, 2));
    process.exit(0);
  })
  .catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  });
