import { ethers } from "ethers";
import "dotenv/config";
import { abi as managerAbi } from "../artifacts/contracts/CampaingManager.sol/CampaingManager.json";

async function main() {
  const provider = new ethers.JsonRpcProvider(process.env.RPC);
  console.log(provider);

  const senderPrivateKey = process.env.PRIVATE_KEY!;
  const senderWallet = new ethers.Wallet(senderPrivateKey, provider);
  console.log("sender: ", senderWallet.address);

  const manager = new ethers.Contract(
    // "0x216223317C808a4BF3653839082dE272edb82615", // C-CHAIN
    '0x0Ee7B92311AbDb66e55FB936776E33D1b94a2caD', // METAFI
    managerAbi,
    senderWallet
  );

  const ADMIN_ROLE = await manager.ADMIN_ROLE();
  await manager.grantRole(
    ADMIN_ROLE,
    "0xf1aAeb6225AB542C758099FD2B52b4E9eA4E9c11"
  );
  await manager.revokeRole(
    ADMIN_ROLE,
    "0xC1e23A2b6dBEC25aF60E2d7208208E77BE4A4547"
  );
}

main().catch(console.error);
