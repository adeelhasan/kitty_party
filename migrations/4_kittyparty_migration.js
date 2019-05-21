const KittyPartyLotteryUpgradable = artifacts.require("KittyPartyLotteryUpgradable");
const OraclizeRandomizer = artifacts.require("OraclizeRandomizer");
const BlockRandomizer = artifacts.require("BlockRandomizer");
const ExternalUintArrayStorage = artifacts.require("ExternalUintArrayStorage");

module.exports = async function(deployer) {

  var storageInstance, randomizerInstance;
  await deployer.deploy(ExternalUintArrayStorage).then((i) => {storageInstance=i;});
  await deployer.deploy(OraclizeRandomizer,storageInstance.address).then((i)=>{randomizerInstance = i;});
  await deployer.deploy(BlockRandomizer);

  await deployer.deploy(KittyPartyLotteryUpgradable,web3.utils.toWei('1', 'ether'), randomizerInstance.address, storageInstance.address);
};
