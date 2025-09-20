// scripts/ultra-simple-test.js
const { ethers } = require("hardhat");

async function main() {
  console.log("🧪 Ultra Simple Donation Test\n");

  const [deployer, admin, donor1, donor2] = await ethers.getSigners();

  console.log("👥 Accounts:");
  console.log(`   Deployer: ${await deployer.getAddress()}`);
  console.log(`   Admin: ${await admin.getAddress()}`);
  console.log(`   Donor1: ${await donor1.getAddress()}`);
  console.log(`   Donor2: ${await donor2.getAddress()}\n`);

  // Deploy contracts
  console.log("🏗️  Deploying contracts...");

  // Deploy forwarder
  const Forwarder = await ethers.getContractFactory("MetafiForwarder");
  const forwarder = await Forwarder.deploy();
  await forwarder.waitForDeployment();
  const forwarderAddress = await forwarder.getAddress();
  console.log(`✅ Forwarder: ${forwarderAddress}`);

  // Deploy token
  const VND = await ethers.getContractFactory("VND");
  const token = await VND.deploy(
    "Test Token",
    "TEST",
    forwarderAddress,
    admin.address
  );
  await token.waitForDeployment();
  const tokenAddress = await token.getAddress();
  console.log(`✅ Token: ${tokenAddress}`);

  // Deploy manager
  const Manager = await ethers.getContractFactory("Manager");
  const manager = await Manager.deploy(forwarderAddress);
  await manager.waitForDeployment();
  const managerAddress = await manager.getAddress();
  console.log(`✅ Manager: ${managerAddress}`);

  // Create campaign
  const now = Math.floor(Date.now() / 1000);
  const createTx = await manager.createCampaign(
    "simple-test",
    now,
    now + 3600, // 1 hour
    ethers.parseEther("10000"), // 10k target
    await admin.getAddress(),
    tokenAddress
  );
  await createTx.wait();

  const campaignAddress = await manager.getCampaign("simple-test");
  // Get campaign contract
  const Campaign = await ethers.getContractFactory("Campaign");
  const campaign = Campaign.attach(campaignAddress);
  console.log(`✅ Campaign: ${campaignAddress}\n`);

  // Setup donors with tokens
  console.log("💰 Setting up donors...");
  await token.mintTo(await donor1.getAddress(), ethers.parseEther("5000"));
  await token.mintTo(await donor2.getAddress(), ethers.parseEther("5000"));
  console.log("✅ Donors funded\n");

  // Test 1: Direct donation
  console.log("1️⃣ Testing Direct Donation");
  try {
    const amount = ethers.parseEther("1000");

    // Approve tokens
    const approveTx = await token
      .connect(donor1)
      .approve(campaignAddress, amount);
    await approveTx.wait();
    console.log("   ✅ Tokens approved");

    // Make donation using call method to avoid TypeScript issues
    const donateInterface = new ethers.Interface([
      "function donate(uint256 _amount, string memory _message) public",
    ]);
    const donateData = donateInterface.encodeFunctionData("donate", [
      amount,
      "Direct donation test",
    ]);

    await campaign.connect(donor1).donate(amount, "");

    // Check campaign state
    const info = await campaign.info();
    console.log(`   💰 Total donations: ${ethers.formatEther(info[5])} tokens`);
    console.log(`   📊 Donation count: ${info[6]}\n`);
  } catch (error) {
    console.log(`   ❌ Direct donation failed: ${error.message}\n`);
  }

  // Test 2: Permit donation
  console.log("2️⃣ Testing Permit Donation");
  try {
    const amount = ethers.parseEther("1500");
    const deadline = Math.floor(Date.now() / 1000) + 3600;

    // Create permit domain and types
    const domain = {
      name: await token.name(),
      version: "1",
      chainId: (await ethers.provider.getNetwork()).chainId,
      verifyingContract: tokenAddress,
    };

    const types = {
      Permit: [
        { name: "owner", type: "address" },
        { name: "spender", type: "address" },
        { name: "value", type: "uint256" },
        { name: "nonce", type: "uint256" },
        { name: "deadline", type: "uint256" },
      ],
    };

    // Create permit data
    const nonce = await token.nonces(await donor2.getAddress());
    const permitData = {
      owner: await donor2.getAddress(),
      spender: campaignAddress,
      value: amount,
      nonce: nonce,
      deadline: deadline,
    };

    // Sign permit
    const signature = await donor2.signTypedData(domain, types, permitData);
    const { v, r, s } = ethers.Signature.from(signature);
    console.log("   ✅ Permit signature created");

    // Execute permit donation using low-level call
    const permitInterface = new ethers.Interface([
      "function donateWithPermit(uint256 _amount, string memory _message, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public",
    ]);
    const permitData2 = permitInterface.encodeFunctionData("donateWithPermit", [
      amount,
      "Permit donation test",
      deadline,
      v,
      r,
      s,
    ]);

    const permitTx = await donor2.sendTransaction({
      to: campaignAddress,
      data: permitData2,
      gasLimit: 300000,
    });
    const permitReceipt = await permitTx.wait();
    console.log(
      `   ✅ Permit donation successful (Gas: ${permitReceipt.gasUsed})`
    );

    // Check campaign state
    const info = await campaign.info();
    console.log(`   💰 Total donations: ${ethers.formatEther(info[5])} tokens`);
    console.log(`   📊 Donation count: ${info[6]}\n`);
  } catch (error) {
    console.log(`   ❌ Permit donation failed: ${error.message}\n`);
  }

  // Test 3: Campaign management
  console.log("3️⃣ Testing Campaign Management");
  try {
    // Stop campaign
    const stopTx = await manager.stopCampaign(campaignAddress);
    await stopTx.wait();
    console.log("   ✅ Campaign stopped");

    // Check status
    const stoppedStatus = await campaign.getStatus();
    console.log(`   📊 Status: ${getStatusName(stoppedStatus)}`);

    // Try donation while stopped (should fail)
    let donationBlocked = false;
    try {
      await token
        .connect(donor1)
        .approve(campaignAddress, ethers.parseEther("500"));

      const donateInterface = new ethers.Interface([
        "function donate(uint256 _amount, string memory _message) public",
      ]);
      const donateData = donateInterface.encodeFunctionData("donate", [
        ethers.parseEther("500"),
        "Should fail",
      ]);

      await donor1.sendTransaction({
        to: campaignAddress,
        data: donateData,
        gasLimit: 200000,
      });
    } catch {
      donationBlocked = true;
      console.log("   ✅ Donation correctly blocked when stopped");
    }

    // Resume campaign
    const resumeTx = await manager.resumeCampaign(campaignAddress);
    await resumeTx.wait();
    console.log("   ✅ Campaign resumed");

    // Check status
    const resumedStatus = await campaign.getStatus();
    console.log(`   📊 Status: ${getStatusName(resumedStatus)}`);

    // Try donation after resume (should work)
    const donateInterface2 = new ethers.Interface([
      "function donate(uint256 _amount, string memory _message) public",
    ]);
    const donateData2 = donateInterface2.encodeFunctionData("donate", [
      ethers.parseEther("500"),
      "After resume",
    ]);

    const resumeDonateTx = await donor1.sendTransaction({
      to: campaignAddress,
      data: donateData2,
      gasLimit: 200000,
    });
    await resumeDonateTx.wait();
    console.log("   ✅ Donation successful after resume\n");
  } catch (error) {
    console.log(`   ❌ Campaign management failed: ${error.message}\n`);
  }

  // Test 4: Error conditions
  console.log("4️⃣ Testing Error Conditions");

  // Test zero donation
  try {
    const donateInterface = new ethers.Interface([
      "function donate(uint256 _amount, string memory _message) public",
    ]);
    const donateData = donateInterface.encodeFunctionData("donate", [
      0,
      "Zero test",
    ]);

    await donor1.sendTransaction({
      to: campaignAddress,
      data: donateData,
      gasLimit: 200000,
    });
    console.log("   ❌ Zero donation should have failed");
  } catch {
    console.log("   ✅ Zero donation correctly rejected");
  }

  // Test no allowance
  try {
    const donateInterface = new ethers.Interface([
      "function donate(uint256 _amount, string memory _message) public",
    ]);
    const donateData = donateInterface.encodeFunctionData("donate", [
      ethers.parseEther("1000"),
      "No allowance",
    ]);

    await donor2.sendTransaction({
      to: campaignAddress,
      data: donateData,
      gasLimit: 200000,
    });
    console.log("   ❌ No allowance donation should have failed");
  } catch {
    console.log("   ✅ No allowance donation correctly rejected");
  }

  // Final state
  console.log("\n📊 Final Campaign State:");
  const finalInfo = await campaign.info();
  console.log(
    `   Start Time: ${new Date(Number(finalInfo[0]) * 1000).toLocaleString()}`
  );
  console.log(
    `   End Time: ${new Date(Number(finalInfo[1]) * 1000).toLocaleString()}`
  );
  console.log(`   Target: ${ethers.formatEther(finalInfo[2])} tokens`);
  console.log(`   Admin: ${finalInfo[3]}`);
  console.log(`   Status: ${getStatusName(finalInfo[4])}`);
  console.log(`   Total Donations: ${ethers.formatEther(finalInfo[5])} tokens`);
  console.log(`   Donation Count: ${finalInfo[6]}`);

  // ERC-2771 verification
  console.log("\n🔗 ERC-2771 Verification:");
  const trustedForwarder = await campaign.getTrustedForwarder();
  const supportsPermit = await campaign.supportsPermit();
  console.log(`   Trusted Forwarder: ${trustedForwarder}`);
  console.log(`   Supports Permit: ${supportsPermit}`);
  console.log(`   Forwarder Match: ${trustedForwarder === forwarderAddress}`);

  console.log("\n🎉 Ultra simple donation test completed!");

  // Return addresses for further testing
  return {
    forwarder: forwarderAddress,
    token: tokenAddress,
    manager: managerAddress,
    campaign: campaignAddress,
  };
}

function getStatusName(status) {
  const names = [
    "WAITING",
    "ON_GOING",
    "FINISHED",
    "COMPLETE_TARGET",
    "PAUSED",
  ];
  return names[status] || "UNKNOWN";
}

// Execute if called directly
if (require.main === module) {
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error("❌ Test failed:", error);
      process.exit(1);
    });
}

module.exports = { main };
