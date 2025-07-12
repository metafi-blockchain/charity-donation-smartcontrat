import { ethers, MaxUint256 } from "ethers";
import "dotenv/config";

async function main() {
  const erc20Abi = [
    "function approve(address spender, uint256 amount) public returns (bool)",
  ];

  const provider = new ethers.JsonRpcProvider(process.env.TESTNET_RPC);

  const privateKeys = [
    "0xca44bd7a6b274456586cbf0af26c5a50574169f3c7757dab6ff93f984da65e9c",
    "0x8f63dff2ca51aa98f5b633a848dbaabc214d5529a464c57ed7944a16953bf360",
    "0xfc66030af1ae407bab3a70341e2e1fc085beb4a48741c3e7c1b10b5a64f197fa",
    "0xaaf116a598a89f1b1a4cb5f65dc634607207846555dc87edf1c62ab6ac22a713",
    "0x012a093865de78d79e025a244f18c8b96e53a622f1e0123e666637a675eb2e2e",
    "0x52bfe51e066209835e103d0a8fef3ccca26d515543a3b219557da7ffeeebe60a",
    "0xcac1f6b10f1bea0730d2c04fa478b4f9b673d735d71e5ffe8aefbef1715ed9e2",
    "0xc41d19ac577948637fc8c3596a85d5ba8392bca6fedba6d6be9959eeae5cbcbc",
    "0xbd27d0fb665866b1d2d1e43b890de432de5a6718be40e3db04d8488564db7697",
    "0xf350ab6374a8a35400a16c4bfb02af3b88624efb43b66d1c1fa67f843d07a929",
  ];

  // 4. Create and send transaction
  for (const privateKey of privateKeys) {
    const wallet = new ethers.Wallet(privateKey, provider);

    const tokenContract = new ethers.Contract(
      "0x64d4fA0820202039F9fc00ec9B48966674E7470A",
      erc20Abi,
      wallet
    );

    const tx = await tokenContract.approve("", MaxUint256);
    console.log("Transaction hash:", tx.hash);

    const receipt = await tx.wait();
  }
}

main().catch(console.error);
