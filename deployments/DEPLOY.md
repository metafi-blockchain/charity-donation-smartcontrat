# Manager and Campaign Deployment Guide

This guide shows how to deploy the Manager contract and create demo campaigns with ERC-2771 meta-transaction support.

## Prerequisites

```bash
npm install
npx hardhat compile
```

## Quick Deployment

### Method 1: Using Hardhat Script

```bash
# Deploy on local network
npx hardhat run scripts/deploy-manager-and-campaign.ts --network localhost

# Deploy on testnet (e.g., Avalanche Fuji)
npx hardhat run scripts/deploy-manager-and-campaign.ts --network fuji
```

### Method 2: Using Hardhat Task

```bash
# Deploy everything with defaults
npx hardhat deploy-demo --network localhost

# Deploy with custom admin
npx hardhat deploy-demo --admin 0x742d35Cc6634C0532925a3b8D0C8b6c6e0822b8b --network localhost

# Deploy with existing forwarder
npx hardhat deploy-demo --forwarder 0x6991dfA95779a152b95f4D89b0bd1Eb57D9409C6 --network localhost
```

## Step-by-Step Manual Deployment

### 1. Deploy MinimalForwarder

```typescript
const MinimalForwarder = await ethers.getContractFactory("MinimalForwarder");
const forwarder = await MinimalForwarder.deploy();
await forwarder.waitForDeployment();
```

### 2. Deploy MockERC20WithPermit

```typescript
const Token = await ethers.getContractFactory("MockERC20WithPermit");
const token = await Token.deploy(
  "Campaign Token",
  "CAMP", 
  ethers.parseEther("1000000")
);
await token.waitForDeployment();
```

### 3. Deploy Manager

```typescript
const Manager = await ethers.getContractFactory("Manager");
const manager = await Manager.deploy(forwarderAddress);
await manager.waitForDeployment();
```

### 4. Create Campaign

```typescript
await manager.createCampaign(
  "demo-campaign",                    // ID
  Math.floor(Date.now() / 1000),     // Start time (now)
  Math.floor(Date.now() / 1000) + (30 * 24 * 60 * 60), // End time (30 days)
  ethers.parseEther("50000"),        // Target (50,000 tokens)
  adminAddress,                      // Campaign admin
  tokenAddress                       // Token contract
);
```

## Creating Additional Campaigns

### Using Hardhat Task

```bash
# Create campaign with target
npx hardhat create-campaign \
  --manager 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  --id "my-campaign" \
  --token 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 \
  --admin 0x742d35Cc6634C0532925a3b8D0C8b6c6e0822b8b \
  --target "10000" \
  --duration "60" \
  --network localhost
```

### Programmatically

```typescript
// Get manager contract
const manager = await ethers.getContractAt("Manager", managerAddress);

// Create campaign
const tx = await manager.createCampaign(
  "campaign-id",
  startTime,
  endTime,
  targetAmount,
  adminAddress,
  tokenAddress
);

// Get campaign address
const campaignAddress = await manager.getCampaign("campaign-id");
```

## Testing Donations

### 1. Direct Donation (Traditional)

```typescript
const campaign = await ethers.getContractAt("Campaign", campaignAddress);
const token = await ethers.getContractAt("MockERC20WithPermit", tokenAddress);

// Approve tokens
await token.connect(donor).approve(campaignAddress, amount);

// Donate
await campaign.connect(donor).donate(amount, "My donation message");
```

### 2. Meta-Transaction Donation

```typescript
// Prepare meta-transaction via relayer service
const prepared = await relayer.prepare({
  from: donorAddress,
  to: campaignAddress,
  data: campaign.interface.encodeFunctionData('donate', [amount, message])
});

// Sign with donor's wallet
const signature = await donor.signTypedData(
  prepared.domain,
  prepared.types,
  prepared.request
);

// Execute via relayer
await relayer.execute({ ...prepared.request, signature });
```

### 3. Permit-Based Donation (Gasless)

```typescript
// Sign permit
const permitSignature = await signPermit(
  token,
  donor,
  campaignAddress,
  amount,
  deadline
);

// Prepare meta-transaction for donateWithPermit
const prepared = await relayer.prepare({
  from: donorAddress,
  to: campaignAddress,
  data: campaign.interface.encodeFunctionData('donateWithPermit', [
    amount,
    message,
    deadline,
    permitSignature.v,
    permitSignature.r,
    permitSignature.s
  ])
});

// Execute via relayer (user pays no gas!)
await relayer.execute({ ...prepared.request, signature });
```

## Environment Configuration

After deployment, update your environment files:

### For Relayer Service (.env)

```bash
# From deployment output
FORWARDER_CONTRACT_ADDRESS=0x6991dfA95779a152b95f4D89b0bd1Eb57D9409C6
CHAIN_ID=31337
RPC_URL=http://localhost:8545
PRIVATE_KEY=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a2875c4e
```

### For Client Application

```typescript
const CONFIG = {
  relayerUrl: 'http://localhost:3000',
  campaignContractAddress: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
  tokenContractAddress: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
  rpcUrl: 'http://localhost:8545',
};
```

## Verification Commands

### Check Campaign Status

```bash
npx hardhat console --network localhost
```

```javascript
const manager = await ethers.getContractAt("Manager", "MANAGER_ADDRESS");
const campaignInfo = await manager.getCampaignInfo("CAMPAIGN_ADDRESS");
console.log("Campaign Info:", campaignInfo);
```

### Check Token Balances

```javascript
const token = await ethers.getContractAt("MockERC20WithPermit", "TOKEN_ADDRESS");
const balance = await token.balanceOf("USER_ADDRESS");
console.log("Balance:", ethers.formatEther(balance));
```

### Check Meta-Transaction Support

```javascript
const campaigns = ["CAMPAIGN_ADDRESS_1", "CAMPAIGN_ADDRESS_2"];
const supported = await manager.checkMetaTransactionSupport(campaigns);
console.log("Meta-tx support:", supported);
```

## Manager Functions

### Emergency Controls

```typescript
// Stop campaign
await manager.stopCampaign(campaignAddress);

// Resume campaign  
await manager.resumeCampaign(campaignAddress);

// Update trusted forwarder for future campaigns
await manager.updateTrustedForwarder(newForwarderAddress);
```

### Campaign Management

```typescript
// Get campaign by ID
const campaignAddress = await manager.getCampaign("campaign-id");

// Get all campaigns (paginated)
const campaigns = await manager.getCampaigns(0, 10); // Start index 0, count 10

// Check if campaign exists
const exists = await manager.exist(campaignAddress);

// Get comprehensive campaign info
const info = await manager.getCampaignInfo(campaignAddress);
```

## Package.json Scripts

Add these to your `package.json`:

```json
{
  "scripts": {
    "deploy:local": "hardhat deploy-demo --network localhost",
    "deploy:fuji": "hardhat deploy-demo --network fuji",
    "create:campaign": "hardhat create-campaign --network localhost",
    "compile": "hardhat compile",
    "test": "hardhat test",
    "node": "hardhat node"
  }
}
```

## Troubleshooting

### Common Issues

1. **"UNPREDICTABLE_GAS_LIMIT"**
   - Ensure token contract supports the required functions
   - Check that addresses are valid

2. **"Insufficient allowance"**
   - User needs to approve tokens before donation
   - For permit donations, signature must be valid

3. **"Campaign not found"**
   - Verify campaign was created successfully
   - Check campaign ID spelling

4. **Meta-transaction fails**
   - Verify trusted forwarder address
   - Ensure relayer service is running
   - Check signature validity

### Debug Tips

```typescript
// Check campaign status
const status = await campaign.getStatus();
console.log("Status:", status); // 0=WAITING, 1=ON_GOING, 2=FINISHED, 3=COMPLETE_TARGET, 4=PAUSED

// Check permit support
const supportsPermit = await campaign.supportsPermit();
console.log("Supports permit:", supportsPermit);

// Check if stopped by manager
const isStopped = await campaign.isStopped();
console.log("Is stopped:", isStopped);

// Check trusted forwarder
const trustedForwarder = await campaign.getTrustedForwarder();
console.log("Trusted forwarder:", trustedForwarder);

// Check token allowance
const allowance = await token.allowance(userAddress, campaignAddress);
console.log("Allowance:", ethers.formatEther(allowance));
```

## Integration with Relayer Service

### Update Relayer Configuration

```typescript
// src/config/deployment.ts
export const DEPLOYMENT_CONFIG = {
  localhost: {
    manager: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
    forwarder: "0x6991dfA95779a152b95f4D89b0bd1Eb57D9409C6",
    sampleCampaign: "0x8ba1f109551bD432803012645Hac136c90b3ce32",
    sampleToken: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
  },
  fuji: {
    manager: "YOUR_FUJI_MANAGER_ADDRESS",
    forwarder: "YOUR_FUJI_FORWARDER_ADDRESS"
  }
};
```

### Update Client Test Configuration

```typescript
// Update CONFIG in client.ts
const CONFIG = {
  relayerUrl: 'http://localhost:3000',
  userPrivateKey: '0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a2875c4e',
  campaignContractAddress: '0x8ba1f109551bD432803012645Hac136c90b3ce32', // From deployment
  tokenContractAddress: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',    // From deployment
  rpcUrl: 'http://localhost:8545',
  donationAmount: '1000000000000000000', // 1 token
  donationMessage: 'Supporting the campaign via meta-transaction!',
};
```

## Production Deployment Checklist

### Before Mainnet Deployment

- [ ] Remove `freeMint()` function from token contract
- [ ] Set proper access controls on Manager
- [ ] Deploy on testnet first
- [ ] Verify all contracts on block explorer
- [ ] Test complete donation flow
- [ ] Test emergency stop/resume functionality
- [ ] Audit smart contracts
- [ ] Set up monitoring and alerts

### Security Considerations

1. **Trusted Forwarder**: Only use audited forwarder contracts
2. **Access Controls**: Ensure only authorized addresses can manage campaigns
3. **Token Security**: Verify token contracts before creating campaigns
4. **Permit Replay**: Permit signatures have deadlines to prevent replays
5. **Emergency Stops**: Manager can pause campaigns in emergencies

## Advanced Usage

### Custom Forwarder Integration

If using a custom forwarder:

```typescript
// Deploy custom forwarder
const CustomForwarder = await ethers.getContractFactory("CustomForwarder");
const customForwarder = await CustomForwarder.deploy();

// Update manager to use new forwarder
await manager.updateTrustedForwarder(await customForwarder.getAddress());

// Create campaigns with new forwarder
await manager.createCampaign(...);
```

### Batch Campaign Creation

```typescript
// Create multiple campaigns at once
const campaignData = [
  {
    id: "campaign-1",
    startTime: now,
    endTime: now + duration,
    target: ethers.parseEther("10000"),
    admin: admin1,
    token: token1
  },
  {
    id: "campaign-2", 
    startTime: now,
    endTime: now + duration,
    target: ethers.parseEther("20000"),
    admin: admin2,
    token: token2
  }
];

await manager.createCampaigns(
  campaignData.map(c => c.id),
  campaignData.map(c => c.startTime),
  campaignData.map(c => c.endTime),
  campaignData.map(c => c.target),
  campaignData.map(c => c.admin),
  campaignData.map(c => c.token)
);
```

### Event Monitoring

```typescript
// Listen for campaign creation events
manager.on("CreateCampaignEvent", (id, startTime, endTime, target, time) => {
  console.log(`New campaign created: ${id}`);
  console.log(`Target: ${ethers.formatEther(target)} tokens`);
});

// Listen for donations
campaign.on("DonationEvent", (user, amount, message, time) => {
  console.log(`Donation: ${ethers.formatEther(amount)} from ${user}`);
  console.log(`Message: ${message}`);
});

// Listen for campaign stops/resumes
manager.on("CampaignStoppedByManager", (campaign, time) => {
  console.log(`Campaign ${campaign} stopped by manager`);
});

manager.on("CampaignResumedByManager", (campaign, time) => {
  console.log(`Campaign ${campaign} resumed by manager`);
});
```

## API Integration Examples

### REST API for Campaign Info

```typescript
// Express.js endpoint example
app.get('/api/campaigns/:id', async (req, res) => {
  try {
    const campaignAddress = await manager.getCampaign(req.params.id);
    if (campaignAddress === ethers.ZeroAddress) {
      return res.status(404).json({ error: 'Campaign not found' });
    }
    
    const info = await manager.getCampaignInfo(campaignAddress);
    
    res.json({
      id: req.params.id,
      address: campaignAddress,
      startTime: Number(info.startTime),
      endTime: Number(info.endTime),
      target: ethers.formatEther(info.target),
      totalDonations: ethers.formatEther(info.totalDonation),
      donationCount: Number(info.countDonation),
      status: getStatusName(info.status),
      supportsMetaTransactions: info.campaignTrustedForwarder !== ethers.ZeroAddress,
      supportsPermit: info.supportsPermit,
      isStopped: info.isStopped
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### GraphQL Schema Example

```graphql
type Campaign {
  id: String!
  address: String!
  startTime: Int!
  endTime: Int!
  target: String!
  totalDonations: String!
  donationCount: Int!
  status: CampaignStatus!
  supportsMetaTransactions: Boolean!
  supportsPermit: Boolean!
  isStopped: Boolean!
  admin: String!
}

enum CampaignStatus {
  WAITING
  ON_GOING
  FINISHED
  COMPLETE_TARGET
  PAUSED
}

type Query {
  campaign(id: String!): Campaign
  campaigns(first: Int, skip: Int): [Campaign!]!
}
```

## Testing Framework

### Unit Tests Example

```typescript
// test/Manager.test.ts
describe("Manager", function () {
  let manager: Contract;
  let token: Contract;
  let forwarder: Contract;
  let admin: SignerWithAddress;

  beforeEach(async function () {
    [deployer, admin] = await ethers.getSigners();
    
    // Deploy contracts
    const MinimalForwarder = await ethers.getContractFactory("MinimalForwarder");
    forwarder = await MinimalForwarder.deploy();
    
    const Token = await ethers.getContractFactory("MockERC20WithPermit");
    token = await Token.deploy("Test", "TEST", ethers.parseEther("1000000"));
    
    const Manager = await ethers.getContractFactory("Manager");
    manager = await Manager.deploy(await forwarder.getAddress());
  });

  it("Should create campaign with correct parameters", async function () {
    const tx = await manager.createCampaign(
      "test-campaign",
      0, // No start time
      0, // No end time  
      ethers.parseEther("1000"),
      admin.address,
      await token.getAddress()
    );
    
    const campaignAddress = await manager.getCampaign("test-campaign");
    expect(campaignAddress).to.not.equal(ethers.ZeroAddress);
    
    const Campaign = await ethers.getContractFactory("Campaign");
    const campaign = Campaign.attach(campaignAddress);
    
    const info = await campaign.info();
    expect(info[3]).to.equal(admin.address); // Admin
    expect(info[2]).to.equal(ethers.parseEther("1000")); // Target
  });

  it("Should support meta-transactions", async function () {
    // Create campaign
    await manager.createCampaign("meta-test", 0, 0, 0, admin.address, await token.getAddress());
    const campaignAddress = await manager.getCampaign("meta-test");
    
    const Campaign = await ethers.getContractFactory("Campaign");
    const campaign = Campaign.attach(campaignAddress);
    
    // Check forwarder
    const trustedForwarder = await campaign.getTrustedForwarder();
    expect(trustedForwarder).to.equal(await forwarder.getAddress());
  });
});
```

## Monitoring and Analytics

### Contract Events Dashboard

```typescript
// Monitor all campaigns for donations
async function monitorDonations() {
  const campaignAddresses = await manager.getCampaigns(0, 100);
  
  for (const address of campaignAddresses) {
    const Campaign = await ethers.getContractFactory("Campaign");
    const campaign = Campaign.attach(address);
    
    campaign.on("DonationEvent", (user, amount, message, time, event) => {
      // Store in database or send to analytics
      analytics.track({
        event: 'donation',
        campaign: address,
        donor: user,
        amount: ethers.formatEther(amount),
        message: message,
        timestamp: Number(time),
        transactionHash: event.transactionHash
      });
    });
  }
}
```

This comprehensive guide provides everything needed to deploy, configure, and integrate the Manager and Campaign contracts with ERC-2771 meta-transaction support. The deployment scripts handle all the complexity while providing flexibility for different network configurations and use cases.