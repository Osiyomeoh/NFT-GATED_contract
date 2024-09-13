import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const NFTGatedEventModule = buildModule("NFTGatedEventModule", (m) => {
  const nftContractAddress = "0x2Ee46Fd1A59D878A8179BC87d706714FFa201e09";

  // Deploy the NFTGatedEvent contract with the constructor parameters
  const nftGatedEvent = m.contract("NFTGatedEvent", [nftContractAddress]);

  return { nftGatedEvent };
});

export default NFTGatedEventModule;
//NFTGatedEventModule#NFTGatedEvent - 0x90dB8dCFB4175De0111552F4605776eF6Fa887c8