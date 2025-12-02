import { ethers } from "ethers";
import "dotenv/config";
import { abi } from "../artifacts/contracts/TokenMinter.sol/TokenMinter.json";

async function main() {
  
  // 1. Connect to Ethereum node (e.g., Ganache or Infura)
  const provider = new ethers.JsonRpcProvider(process.env.MAINNET_RPC);

  // 2. Load sender's wallet using private key
  const senderPrivateKey = process.env.MAINNET_PRIVATE_KEY!; // Replace with the real private key
  const senderWallet = new ethers.Wallet(senderPrivateKey, provider);

  const tokenMinter = new ethers.Contract(
    "0x9568bFf2eD93210A62a701f41a8328f5AF9791D6",
    abi,
    senderWallet
  );

  const admins = ["0x57708cdd3d5eb250c94cd82f6b772220e883bb52"];
  const isAdmins = [true];

  await tokenMinter.setupAdmins(admins, isAdmins);
}

main().catch(console.error);
