const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Campaign", function () {
  async function deployCampaign() {
    // Contracts are deployed using the first signer/account by default
    const [
      admin,
      campaignAdmin,
      otherCampaignAdmin,
      user1,
      user2,
      otherAccount,
    ] = await ethers.getSigners();

    const UserStorage = await ethers.getContractFactory("UserStorage");
    const userStorage = await UserStorage.deploy();

    const UserManager = await ethers.getContractFactory("UserManager");
    const userManager = await UserManager.deploy(userStorage);

    await userStorage.setupUserManager(userManager);

    const RateManager = await ethers.getContractFactory("RateManager");
    const rateManager = await RateManager.deploy();

    const Manager = await ethers.getContractFactory("Manager");
    const manager = await Manager.deploy(rateManager, userManager);

    await userManager.setupManager(await manager.getAddress());

    const Token = await ethers.getContractFactory("Token");
    const vnd = await Token.deploy();
    // await vnd.mintTo(user1, 10000000000n);
    // await vnd.mintTo(user2, 10000000000n);

    const usdt = await Token.deploy();
    await usdt.mintTo(user1, 10000000000n);
    await usdt.mintTo(user2, 10000000000n);

    return {
      manager,
      rateManager,
      userManager,
      usdt,
      vnd,
      user1,
      user2,
      admin,
      campaignAdmin,
      otherCampaignAdmin,
      otherAccount,
    };
  }

  describe("Testing", function () {
    // it("Should set the right rate", async function () {
    //   const { rateManager, usdt, vnd } = await loadFixture(deployCampaign);

    //   await rateManager.setupRate(usdt, 25000);
    //   expect(await rateManager.convert(usdt, 1)).to.equal(25000n);
    // });
    it("Should set the right campaign", async function () {
      const {
        manager,
        rateManager,
        userManager,
        usdt,
        vnd,
        user1,
        user2,
        otherCampaignAdmin,
        campaignAdmin,
      } = await loadFixture(deployCampaign);
      await rateManager.setupRate(usdt, 25000);

      //CREATE CAMPAIGN
      const name = "CAMPAIGN-1";
      const ONE_MIN_IN_SECONDS = 60;
      const startTime = await time.latest();
      const endTime = startTime + ONE_MIN_IN_SECONDS;

      await manager.createCampaign(name, startTime, endTime, campaignAdmin);

      // check campaign length
      expect(await manager.getCampaignsLength()).to.equal(1n);
      //check name, start, end time
      const campaigns = await manager.getCampaigns(0, 10);
      const campaign = await ethers.getContractAt("Campaign", campaigns[0]);

      expect(await campaign.name()).to.equal(name);
      expect(await campaign.startTime()).to.equal(startTime);
      expect(await campaign.endTime()).to.equal(endTime);
      expect(await campaign.admin()).to.equal(campaignAdmin);

      //Set campaing admin
      await manager.setupCampaignAdmin(campaigns[0], otherCampaignAdmin);

      expect(await campaign.admin()).to.equal(otherCampaignAdmin);

      //User 1 donate
      await usdt.connect(user1).approve(campaigns[0], 1);
      await campaign.connect(user1).donate(usdt, 1);

      //User 2 donate
      await usdt.connect(user2).approve(campaigns[0], 2);
      await campaign.connect(user2).donate(usdt, 2);

      // Check list donors
      expect(await campaign.getDonorsLength()).to.equal(2);
      let data = await campaign.getDonors(0, 10);
      expect((await campaign.getDonors(0, 10))[0]).to.deep.equal([
        user1.address,
        user2.address,
      ]);

      //Check campaign balane
      expect(await usdt.balanceOf(campaigns[0])).to.equal(3);

      //check campaign list
      expect(await manager.getCampaignsLength()).to.equal(1);

      //Check user manager
      expect(await userManager.getCampaignsLength(user1.address)).to.equal(1);
      expect(await userManager.getCampaignsLength(user2.address)).to.equal(1);
      expect(
        await userManager.getCampaigns(user1.address, 0, 10)
      ).to.deep.equal([await campaign.getAddress()]);

      expect(
        await userManager.getCampaigns(user2.address, 0, 10)
      ).to.deep.equal([await campaign.getAddress()]);
    });
  });
});
