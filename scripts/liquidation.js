const LendCore = artifacts.require("LendCore");
const TestNFT = artifacts.require("TestNFT");
const NFTFToken = artifacts.require("NFTFToken");

module.exports = async (callback) => {
  try {
    const Lend = await LendCore.deployed();
    const NFT = await TestNFT.deployed();
    const NFTF = await NFTFToken.deployed();

    const accounts = await web3.eth.getAccounts();
    const account1 = accounts[0];
    const account8 = accounts[7];

    console.log("account1 address:", account1);
    console.log("account8 address:", account8);

    const tokenId = await NFT._nextId.call();
    const nftId = web3.utils.soliditySha3(NFT.address, tokenId - 1);

    console.log("This liquidation will success\n");
    const liq_tx2 = await Lend.liquidation(
      nftId,
      web3.utils.toWei("50", "ether"),
      { from: account1 }
    );
    console.log(liq_tx2.tx);

    const owner = await NFT.ownerOf(tokenId - 1, { from: account1 });
    if (owner == account1) {
      console.log("The owner has been transferred");
    }

    // console.log("This liquidation should fail\n");
    // await Lend.liquidation(nftId, web3.utils.toWei("5000", "ether"), {
    //   from: account1,
    // });

    callback(true);
  } catch (err) {
    callback(err);
  }
};
