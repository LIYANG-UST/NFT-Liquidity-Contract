const NFTFToken = artifacts.require("NFTFToken");
const LendCore = artifacts.require("LendCore");
const TestNFT = artifacts.require("TestNFT");

const bidRewardPerBlock = web3.utils.toBN(10e18);
const feeRate = 5;

module.exports = async function (deployer) {
  await deployer.deploy(NFTFToken);
  await deployer.deploy(TestNFT);
  await deployer.deploy(
    LendCore,
    bidRewardPerBlock,
    feeRate,
    NFTFToken.address
  );
};
