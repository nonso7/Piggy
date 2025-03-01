import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require('dotenv').config()

const { ALCHEMY_BASE_SEPOLIA_API_KEY_URL, PRIVATE_KEY, BASESCAN_API_KEY } = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    base_sepolia: {
      url: ALCHEMY_BASE_SEPOLIA_API_KEY_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    }
  },
  etherscan: {
    apiKey: BASESCAN_API_KEY,
    customChains: [
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org",
        },
      },
    ],
  },

  sourcify: {
    enabled: true,
  },
};

export default config;

