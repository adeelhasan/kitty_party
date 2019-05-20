const KittyPartyAuction = artifacts.require("KittyPartyAuction");

module.exports = function(deployer) {
  deployer.deploy(KittyPartyAuction,web3.utils.toWei('1', 'ether'));
};
