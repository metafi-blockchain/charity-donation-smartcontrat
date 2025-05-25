import { ethers, network, run } from "hardhat";

const main = async () => {
  const networkName = network.name;
  console.log(`Deploying to ${networkName} network...`);

  // Compile contracts.
  await run("compile");
  console.log("Compiled contracts.");

  // Deploy contract
  const VND = await ethers.getContractFactory("Token");
  const vnd = await VND.deploy();
  console.log(`VND:  ${await vnd.getAddress()}`);

  const TokenMinter = await ethers.getContractFactory("TokenMinter");
  const tokenMinter = await TokenMinter.deploy();
  console.log(`TokenMinter:  ${await tokenMinter.getAddress()}`);

  vnd.setupMinter(await tokenMinter.getAddress(), true);
  tokenMinter.setupAdmin("0xC97da29804F8565D59B58221fA36C82e765F7638", true);
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
