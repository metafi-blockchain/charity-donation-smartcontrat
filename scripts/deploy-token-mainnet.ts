import { ethers, network, run } from "hardhat";

const main = async () => {
  const networkName = network.name;
  console.log(`Deploying to ${networkName} network...`);

  // Compile contracts.
  await run("compile");
  console.log("Compiled contracts.");

  // Deploy contract
  // const VND = await ethers.getContractFactory("Token");
  // const vnd = await VND.deploy();
  // console.log(`VND:  ${await vnd.getAddress()}`);

  const TokenMinter = await ethers.getContractFactory("TokenMinter");
  const tokenMinter = await TokenMinter.deploy();
  console.log(`TokenMinter:  ${await tokenMinter.getAddress()}`);

  // vnd.setupMinter(await tokenMinter.getAddress(), true);
  let admins = [];
  let isAdmins = [];
  for (let i = 0; i < 10; i++) {
    const newWallet = ethers.Wallet.createRandom();
    console.log(`Address: ${newWallet.address}`);
    console.log(`PrivateKey: ${newWallet.privateKey}`);
    admins.push(newWallet.address);
    isAdmins.push(true);
  }
  await tokenMinter.setupAdmins(admins, isAdmins);
};

// function sleep(ms: number): Promise<void> {
//   return new Promise((resolve) => setTimeout(resolve, ms));
// }

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
