const LendCore = artifacts.require("LendCore");
const TestNFT = artifacts.require("TestNFT");

module.exports = async (callback) => {
  try {
    const Lend = await LendCore.deployed();
    const NFT = await TestNFT.deployed();

    const accounts = await web3.eth.getAccounts();
    const account1 = accounts[0];

    // Account 8 => deposit
    const account8 = accounts[7];

    console.log("account1 address:", account1);
    console.log("account8 address:", account8);

    const tokenId = await NFT._nextId.call({ from: account8 });

    const tx1 = await NFT.mint(account8, { from: account1 });
    console.log(tx1.tx);

    await NFT.approve(Lend.address, tokenId, { from: account8 });

    const tx2 = await Lend.depositNFT(NFT.address, tokenId, { from: account8 });
    console.log(tx2.tx);

    const tx3 = await Lend.showUserNFTList({ from: account8 });
    console.log(tx3);

    callback(true);
  } catch (err) {
    callback(err);
  }
};
