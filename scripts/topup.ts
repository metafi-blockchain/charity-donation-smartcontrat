import { ethers } from "ethers";
import "dotenv/config";

async function main() {
  // 1. Connect to Ethereum node (e.g., Ganache or Infura)
  const provider = new ethers.JsonRpcProvider(process.env.TESTNET_RPC);

  // 2. Load sender's wallet using private key
  const senderPrivateKey = process.env.TESTNET_PRIVATE_KEY!; // Replace with the real private key
  const senderWallet = new ethers.Wallet(senderPrivateKey, provider);

  // 3. Define recipient address and amount to send (in ETH)
  const recipients = [
    "0xB46b880EF5b88763526EE329b089278cba83BC7e",
    "0xAb43003D0B1f3Fe185fa0cBA66242ffdcc227183",
    "0x3C507b5205d3b813D253729c48EE23274eAceA75",
    "0x0B7f886f4733E66Aaa745276B113C940827E0F41",
    "0xf9fA524839bcf48238b7FfEE96564172b940a42C",
    "0xDac666BFfc3dA42614c4a9CE9eC960159BaD7AdE",
    "0x163C5DefF31945DB9D04DCFA312fcD2D9C4d5D8B",
    "0x566F8af018bC700ABFcC321f5d7DfbE6dc30166C",
    "0x0E26d11e8c04B65f93367e0516331cB90232646a",
    "0x0baCf9B10D6EC093a8Eb0Fa90677b1eA688d2989",
  ];
  const amountInEth = "0.01";

  // 4. Create and send transaction
  for (const recipient of recipients) {
    const tx = await senderWallet.sendTransaction({
      to: recipient,
      value: ethers.parseEther(amountInEth),
    });

    console.log("Transaction sent:", tx.hash);

    // 5. Wait for confirmation
    const receipt = await tx.wait();

  }
  
}

main().catch(console.error);
