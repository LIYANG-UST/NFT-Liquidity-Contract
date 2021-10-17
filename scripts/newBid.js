const LendCore = artifacts.require("LendCore");
const TestNFT = artifacts.require("TestNFT");
const NFTFToken = artifacts.require("NFTFToken");

module.exports = async (callback) => {
  try {
    const Lend = await LendCore.deployed();
    const NFT = await TestNFT.deployed();
    const NFTF = await NFTFToken.deployed();

    const accounts = await web3.eth.getAccounts();
    // Account1 and account2 bid, then account2 redeem bid, only account1 left
    const account1 = accounts[0];
    const account2 = accounts[1];

    console.log("account1 address:", account1);
    console.log("account2 address:", account2);

    await NFTF.mint(account1, web3.utils.toWei("10000", "ether"), {
      from: account1,
    });
    await NFTF.mint(account2, web3.utils.toWei("10000", "ether"), {
      from: account1,
    });

    const balance1 = await NFTF.balanceOf(account1, { from: account1 });
    const balance2 = await NFTF.balanceOf(account2, { from: account1 });

    console.log("User1 Balance:", web3.utils.fromWei(balance1));
    console.log("User2 Balance:", web3.utils.fromWei(balance2));

    const tokenId = await NFT._nextId.call();
    const nftId = web3.utils.soliditySha3(NFT.address, tokenId - 1);

    const interest = web3.utils.toWei("0.001", "ether");

    // Bid 1: from account1
    await NFTF.approve(Lend.address, web3.utils.toWei("1000", "ether"), {
      from: account1,
    });
    const bidAmount1 = web3.utils.toWei("1000", "ether");
    const tx1 = await Lend.newBid(nftId, bidAmount1, interest, 7200, {
      from: account1,
    });
    console.log(tx1.tx);

    // Bid 2: from account2
    await NFTF.approve(Lend.address, web3.utils.toWei("3000", "ether"), {
      from: account2,
    });
    const bidAmount2 = web3.utils.toWei("3000", "ether");
    const tx2 = await Lend.newBid(nftId, bidAmount2, interest, 7800, {
      from: account2,
    });
    console.log(tx2.tx);

    const matchList1 = await Lend.showMatchList(nftId, { from: account1 });
    console.log(matchList1);

    // Redeem Bid from account2
    const bidId = web3.utils.soliditySha3(account2, nftId);
    console.log(bidId);
    const tx3 = await Lend.redeemBid(nftId, bidId, { from: account2 });
    console.log(tx3.tx);

    const matchList = await Lend.showMatchList(nftId, { from: account1 });
    console.log(matchList);

    callback(true);
  } catch (err) {
    callback(err);
  }
};
