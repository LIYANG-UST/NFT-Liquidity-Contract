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

    // 本金1000 利息0.001/block
    await NFTF.mint(account8, web3.utils.toWei("2000", "ether"));

    const balance8_before = await NFTF.balanceOf(account8, { from: account8 });
    console.log("User8 Balance before:", web3.utils.fromWei(balance8_before));

    const interest = await Lend.pendingInterest(nftId);
    const bidinfo = await Lend.showActiveMatch(nftId);
    const amount = bidinfo.bidAmount;

    await NFTF.approve(Lend.address, interest + amount, { from: account8 });

    const tx = await Lend.redeemNFT(nftId, { from: account8 });
    console.log(tx.tx);

    const balance8_after = await NFTF.balanceOf(account8, { from: account8 });
    console.log("User8 Balance after:", web3.utils.fromWei(balance8_after));

    callback(true);
  } catch (err) {
    callback(err);
  }
};
