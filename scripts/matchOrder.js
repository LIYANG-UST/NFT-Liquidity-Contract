const LendCore = artifacts.require("LendCore");
const TestNFT = artifacts.require("TestNFT");
const NFTFToken = artifacts.require("NFTFToken");

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

module.exports = async (callback) => {
  try {
    const Lend = await LendCore.deployed();
    const NFT = await TestNFT.deployed();
    const NFTF = await NFTFToken.deployed();

    const accounts = await web3.eth.getAccounts();
    const account1 = accounts[0];
    const account2 = accounts[1];
    const account8 = accounts[7];

    console.log("account1 address:", account1);
    console.log("account2 address:", account2);

    const balance_before = await NFTF.balanceOf(account8, { from: account8 });
    console.log("Balance before match:", parseInt(balance_before) / 1e18);

    const tokenId = await NFT._nextId.call();
    const nftId = web3.utils.soliditySha3(NFT.address, tokenId - 1);

    const bidOrder = 0; // always match the first bid
    const tx1 = await Lend.matchOrder(nftId, bidOrder, { from: account8 });
    console.log("Match Order Tx Hash:", tx1.tx);

    const balance_after = await NFTF.balanceOf(account8, { from: account8 });
    console.log("Balance after match:", parseInt(balance_after) / 1e18);

    // Test the interest
    const interest1 = await Lend.pendingInterest(nftId);
    console.log("Interest:", parseInt(interest1) / 1e18);

    await NFTF.mint(account1, web3.utils.toWei("10000", "ether"), {
      from: account1,
    });

    const interest2 = await Lend.pendingInterest(nftId);
    console.log("Interest in 1 block:", parseInt(interest2 - interest1) / 1e18);
    callback(true);
  } catch (err) {
    callback(err);
  }
};
