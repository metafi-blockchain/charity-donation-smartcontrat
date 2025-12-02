import { ethers } from "ethers";
import "dotenv/config";
import { abi as camapaignAbi } from "../artifacts/contracts/Campaign.sol/Campaign.json";

async function main() {
  const provider = new ethers.JsonRpcProvider(process.env.RPC);
  console.log(provider);

  const senderPrivateKey = process.env.PRIVATE_KEY!;
  const senderWallet = new ethers.Wallet(senderPrivateKey, provider);
  console.log("sender: ", senderWallet.address);

  const campaign = new ethers.Contract(
    "0x794B4394B624cCD967A2aBF48e2cc42fCD9823D9",
    camapaignAbi,
    senderWallet
  );

  const info = await campaign.info();
  console.log(info);
}

main().catch(console.error);
