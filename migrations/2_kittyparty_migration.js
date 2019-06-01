const KittyPartySequential = artifacts.require("KittyPartySequential");

module.exports = function(deployer) {
  deployer.deploy(KittyPartySequential,web3.utils.toWei('1', 'ether'),{gas: 5000000});
};
