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
  const userStorageAddress = await userStorage.getAddress();
  console.log(`User storage:  ${userStorageAddress} `);

  const UserManager = await ethers.getContractFactory("UserManager");
  const userManager = await UserManager.deploy(userStorageAddress);
  const userManagerAddress = await userManager.getAddress();
  console.log(`User manager:  ${userManagerAddress} `);

  await userStorage.setupUserManager(userManagerAddress);

  const RateManager = await ethers.getContractFactory("RateManager");
  const rateManager = await RateManager.deploy();
  const rateManagerAddress = await rateManager.getAddress();
  console.log(`Rate manager:  ${rateManagerAddress} `);
  await rateManager.setupRate(
    "0xd0FcC782776645278c5239f2cE510683d34F3dBe",
    25000
  );

  const Manager = await ethers.getContractFactory("Manager");
  const manager = await Manager.deploy(rateManagerAddress, userManagerAddress);
  console.log(`Manager: ${await manager.getAddress()}`);

  await userManager.setupManager(await manager.getAddress());
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
