import { ethers, network, run } from "hardhat";

const main = async () => {
  const networkName = network.name;
  console.log(`Deploying to ${networkName} network...`);

  // Compile contracts.
  await run("compile");
  console.log("Compiled contracts.");

  // Deploy contract
  const VND = await ethers.getContractFactory("VND");

  const contract = await VND.deploy();

  // Wait for the contract to be deployed before exiting the script.
  // await contract.d();
  console.log(`Deployed to ${await contract.getAddress()}`);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
