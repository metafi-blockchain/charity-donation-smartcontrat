const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Campaign", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployCampaign() {
    const ONE_MIN_IN_SECONDS = 60;

    const startTime = await time.latest();
    const endTime = startTime + ONE_MIN_IN_SECONDS;

    // Contracts are deployed using the first signer/account by default
    const [admin, otherAccount] = await ethers.getSigners();

    const Manager = await ethers.getContractFactory("Manager");
    const Token = await ethers.getContractFactory("Token");
    const CurrencyConvert = await ethers.getContractFactory("CurrencyConvert");
    const vnd = await Token.deploy();
    const usdt = await Token.deploy();
    const currencyConvert = await CurrencyConvert.deploy();
    const manager = await Manager.deploy(currencyConvert);

    return { manager, currencyConvert, usdt, vnd, admin, otherAccount };
  }

  describe("Testing", function () {
    it("Should set the right rate", async function () {
      const { currencyConvert, usdt, vnd } = await loadFixture(deployCampaign);

      await currencyConvert.setupRate(usdt, 25000);

      expect(await currencyConvert.convert(usdt, 1)).to.equal(25000);
    });
  });
});
