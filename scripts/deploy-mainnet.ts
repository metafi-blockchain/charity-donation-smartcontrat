import { ethers, network, run } from "hardhat";

const main = async () => {
  const networkName = network.name;
  console.log(`Deploying to ${networkName} network...`);

  // Compile contracts.
  await run("compile");
  console.log("Compiled contracts.");

  // Deploy contract
  const VND = await ethers.getContractFactory("VND");
  const vnd = await VND.deploy();
  const vndAddres = await vnd.getAddress();
  console.log(`VND:  ${vndAddres}`);
  await sleep(5000);

  const UserStorage = await ethers.getContractFactory("UserStorage");
  const userStorage = await UserStorage.deploy();
  const userStorageAddress = await userStorage.getAddress();
  console.log(`User storage:  ${userStorageAddress} `);
  await sleep(10000);

  const UserManager = await ethers.getContractFactory("UserManager");
  const userManager = await UserManager.deploy(userStorageAddress);
  const userManagerAddress = await userManager.getAddress();
  console.log(`User manager:  ${userManagerAddress} `);
  await sleep(10000);

  await userStorage.setupUserManager(userManagerAddress);

  const RateManager = await ethers.getContractFactory("RateManager");
  const rateManager = await RateManager.deploy();
  const rateManagerAddress = await rateManager.getAddress();
  console.log(`Rate manager:  ${rateManagerAddress} `);
  await sleep(10000);

  // await rateManager.setupRate(
  //   "0xd0FcC782776645278c5239f2cE510683d34F3dBe",
  //   25000
  // );

  await rateManager.setupRate(vndAddres, 1);
  // await rateManager.setupRate(
  //   "0x0000000000000000000000000000000000000000",
  //   650
  // );

  const Manager = await ethers.getContractFactory("Manager");
  const manager = await Manager.deploy(rateManagerAddress, userManagerAddress);
  console.log(`Manager: ${await manager.getAddress()}`);

  await sleep(10000);
  await userManager.setupManager(await manager.getAddress());
};

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
