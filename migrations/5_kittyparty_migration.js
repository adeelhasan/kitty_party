const KittyPartyLotteryOraclize = artifacts.require("KittyPartyLotteryOraclize");

module.exports = async function(deployer) {

  await deployer.deploy(KittyPartyLotteryOraclize,web3.utils.toWei('1', 'ether'));

};
