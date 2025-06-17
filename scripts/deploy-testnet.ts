import { ethers, network, run } from "hardhat";

const main = async () => {
  const networkName = network.name;
  console.log(`Deploying to ${networkName} network...`);

  // Compile contracts.
  await run("compile");
  console.log("Compiled contracts.");

  // Deploy contract
  // const VND = await ethers.getContractFactory("VND");

  // const contract = await VND.deploy();

  // Wait for the contract to be deployed before exiting the script.
  // await contract.d();
  // console.log(`Deployed to ${await contract.getAddress()}`);

  const UserStorage = await ethers.getContractFactory("UserStorage");
  const userStorage = await UserStorage.deploy();

  // await sleep(1000);

  const userStorageAddress = await userStorage.getAddress();
  console.log(`User storage:  ${userStorageAddress} `);

  const UserManager = await ethers.getContractFactory("UserManager");
  const userManager = await UserManager.deploy(userStorageAddress);
  const userManagerAddress = await userManager.getAddress();
  console.log(`User manager:  ${userManagerAddress} `);

  await sleep(2000);

  await userStorage.setupUserManager(userManagerAddress);

  // const RateManager = await ethers.getContractFactory("RateManager");
  // const rateManager = await RateManager.deploy();
  // const rateManagerAddress = await rateManager.getAddress();
  // console.log(`Rate manager:  ${rateManagerAddress} `);

  // await sleep(1000);

  // await rateManager.setupRate(
  //   "0xd0FcC782776645278c5239f2cE510683d34F3dBe",
  //   25000
  // );

  // await rateManager.setupRate("0x29252DD19B0C4763eBD8D02C6db1DF3A1E0E35f5", 1);
  // await rateManager.setupRate(
  //   "0x0000000000000000000000000000000000000000",
  //   650
  // );

  const Manager = await ethers.getContractFactory("Manager");
  // const manager = await Manager.deploy(rateManagerAddress, userManagerAddress);
  const manager = await Manager.deploy(
    "0x66572B53258AfF686FA7D4aF28394f5be3464D20",
    userManagerAddress
  );
  console.log(`Manager: ${await manager.getAddress()}`);

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
