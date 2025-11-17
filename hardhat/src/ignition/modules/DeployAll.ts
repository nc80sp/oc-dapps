import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("OCModule", (m) => {
  const counter = m.contract("Counter");
  const myNFT = m.contract("MyNFT");
  const paidAccess = m.contract("PaidAccess");
  const multiQuizReward = m.contract("MultiQuizReward");

  return { counter, myNFT, paidAccess, multiQuizReward };
});
