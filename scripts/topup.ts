import { ethers } from "ethers";
import "dotenv/config";

async function main() {
  // 1. Connect to Ethereum node (e.g., Ganache or Infura)
  const provider = new ethers.JsonRpcProvider(process.env.MAINNET_RPC);

  // 2. Load sender's wallet using private key
  const senderPrivateKey = process.env.TESTNET_PRIVATE_KEY!; // Replace with the real private key
  const senderWallet = new ethers.Wallet(senderPrivateKey, provider);

  // 3. Define recipient address and amount to send (in ETH)
  const recipients = [
    "0x1F5a362fCC4e8f64Cdf0531C62C8a96352e60a02",
    "0x81dABa67DbbfC40C40506b911AFF6A43D92CB614",
    "0x0335F00fa38a794CA5E8314c7c56bF8A060959f2",
    "0xE0192e0C823eE198B131Ea5096174a66979f2384",
    "0xE74c955296F945b11FB9cf0e0428264A53754D7F",
    "0xC238aC3Ebe0102BA3B130f62E0f2EB19551ED0b4",
    "0xA582fECFEFd05e5567b5BC4c416Da918800a3dd9",
    "0xa847e5F57bFeC726276d4014EE14861d295638Ad",
    "0x45EDAcF0384f90109830c17C40C7B9b40982881F",
    "0x82fD59c92222b71586BbB2557f476e6534fDc3c0",
  ];
  const amountInEth = "0.1";

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
