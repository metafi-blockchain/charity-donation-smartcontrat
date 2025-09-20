import { ethers } from "ethers";
import "dotenv/config";
import { abi } from "../artifacts/contracts/TokenMinter.sol/TokenMinter.json";

async function main() {
  // 1. Connect to Ethereum node (e.g., Ganache or Infura)
  const provider = new ethers.JsonRpcProvider(process.env.MAINNET_RPC);

  // 2. Load sender's wallet using private key
  const senderPrivateKey = process.env.TESTNET_PRIVATE_KEY!; // Replace with the real private key
  const senderWallet = new ethers.Wallet(senderPrivateKey, provider);

  const tokenMinter = new ethers.Contract(
    "0x53c8F2aaa14f170CcddD24E2EE826B3E17060D69",
    abi,
    senderWallet
  );

  const tokens = ["0xA96a3E7DdB1E43a3e52F741a30915aeaEAfcf7a1"];
  const recipients = ["0x8E955c10Fa4ece26F43f52608B5BBc5eE45c6ba0"];
  const amounts = ["1000000000000000000"];

  await tokenMinter.mintTo(tokens, recipients, amounts, {
    
  });
}

main().catch(console.error);
