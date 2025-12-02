// scripts/deploy-manager-and-campaign.ts
import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

interface DeploymentResult {
  addresses: {
    manager: string;
    // campaign: string;
    token: string;
    forwarder: string;
  };
}

async function main() {
  console.log("🚀 Starting Manager and Campaign Deployment...\n");
  // Get network and deployer info
  const network = await ethers.provider.getNetwork();

  // Get signers
  const [deployer] = await ethers.getSigners();
  // const forwarderAddress = "0x7324c4e6795091E04ecCc868afa2D8e41f1183D8";
  // const vnd = "0x2A260a7fF83dbcD4405B69AE399067F59FD776aa";
  const forwarderAddress = "0x1589Fb115438C7C95D00306C68F9986674b477BD";
  const vnd = "0x6c56B37D0E36b3090CBBefcfaaA0c57a6a05BbF1";

  console.log("👥 Deployment Configuration:");
  console.log(`📋 Deployer: ${deployer.address}`);
  console.log(`👤 Campaign Admin: ${deployer.address}`);

  // Step 1: Deploy Manager
  console.log("3️⃣ Deploying Manager...");
  const Manager = await ethers.getContractFactory("CampaingManager");
  const manager = await Manager.deploy(forwarderAddress);
  await manager.waitForDeployment();
  const managerAddress = await manager.getAddress();
  console.log(`✅ Manager deployed at: ${managerAddress}\n`);

  // Step 2: Check can grant role
  const ADMIN_ROLE = await manager.ADMIN_ROLE();
  const createTx = await manager.grantRole(
    ADMIN_ROLE,
    "0xC1e23A2b6dBEC25aF60E2d7208208E77BE4A4547"
  );

  const createReceipt = await createTx.wait();

  // // Step 2: Create Demo Campaign
  // console.log("4️⃣ Creating Demo Campaign...");

  // const campaignConfig = {
  //   id: "demo-campaign-2024",
  //   startTime: 0, // Start now
  //   endTime: 0, // End in 30 days
  //   target: 0, // Target: 50,000 tokens
  //   admin: deployer.address,
  //   token: vnd,
  // };

  // // const createTx = await manager.createCampaign(
  // //   campaignConfig.id,
  // //   campaignConfig.startTime,
  // //   campaignConfig.endTime,
  // //   campaignConfig.target,
  // //   campaignConfig.admin,
  // //   campaignConfig.token
  // // );

  // // const createReceipt = await createTx.wait();

  // // // Get campaign address from event
  // // const createEvent = createReceipt?.logs.find(
  // //   (log: any) => log.fragment?.name === "CreateCampaignEvent"
  // // );

  // // const campaignAddress = await manager.getCampaign(campaignConfig.id);
  // // console.log(`✅ Campaign created at: ${campaignAddress}`);

  // // Get campaign contract instance
  // const Campaign = await ethers.getContractFactory("Campaign");
  // const campaign = Campaign.attach(campaignAddress);

  // console.log("🎉 Deployment Complete!");
  // console.log("=".repeat(50));
  // console.log("📋 Contract Addresses:");
  // console.log(`   Manager: ${managerAddress}`);
  // console.log(`   Campaign: ${campaignAddress}`);
  // console.log(`   Token: ${vnd}`);
  // console.log(`   Forwarder: ${forwarderAddress}`);
  // console.log("=".repeat(50));

  // console.log("\n🔗 Next Steps:");
  // console.log("1. Update your relayer service with these addresses");
  // console.log("2. Update your client configuration");
  // console.log("3. Test meta-transactions with your relayer");
  // console.log("4. Try permit-based donations for gasless experience\n");

  // Summary
  const deploymentResult: DeploymentResult = {
    addresses: {
      manager: managerAddress,
      // campaign: campaignAddress,
      token: vnd,
      forwarder: forwarderAddress,
    },
  };

  // Save addresses to file
  const fs = require("fs");
  const deploymentData = {
    network: network.name,
    chainId: network.chainId.toString(),
    timestamp: new Date().toISOString(),
    contracts: deploymentResult.addresses,
    // campaignConfig: {
    //   id: campaignConfig.id,
    //   startTime: campaignConfig.startTime,
    //   endTime: campaignConfig.endTime,
    //   target: campaignConfig.target.toString(),
    //   admin: campaignConfig.admin,
    // },
    accounts: {
      deployer: deployer.address,
      // campaignAdmin: deployer.address,
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
    `${network.name}-${network.chainId}-manager.json`
  );
  fs.writeFileSync(deploymentFile, JSON.stringify(deploymentData, null, 2));

  console.log("💾 Deployment info saved to:", deploymentFile);
  console.log("");

  return deploymentResult;
}

// Helper function to convert status enum to readable name
function getStatusName(status: number): string {
  const statusNames = [
    "WAITING",
    "ON_GOING",
    "FINISHED",
    "COMPLETE_TARGET",
    "PAUSED",
  ];
  return statusNames[status] || "UNKNOWN";
}

// Execute deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });

// Export for testing
export { main as deployManagerAndCampaign };
