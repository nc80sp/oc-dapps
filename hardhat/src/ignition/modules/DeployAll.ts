import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("OCModule", (m) => {
  const openCampusPass = m.contract("OpenCampusPass");

  return { openCampusPass };
});
