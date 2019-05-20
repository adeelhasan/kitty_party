
var KittyPartyLotteryUpgradable = artifacts.require("./KittyPartyLotteryUpgradable.sol");
var OraclizeRandomizer = artifacts.require("./OraclizeRandomizer.sol");
var BlockRandomizer = artifacts.require("./BlockRandomizer.sol");


contract("KittyPartyLotteryUpgradable", function(accounts){
    it("should be able to switch the randomizer", async function(){
        let kplottery = await KittyPartyLotteryUpgradable.deployed();
        let oraclizeRandomizer = await OraclizeRandomizer.deployed();
        let blockRandomizer = await BlockRandomizer.deployed();

        var intialRandomizerName, updatedRandomizerName;

        //the initial randomizer is set in the deployment script
        await kplottery.getTypeOfRandomizer().then((r)=>{intialRandomizerName = r;});
        await kplottery.updateRandomizer(blockRandomizer.address);
        await kplottery.getTypeOfRandomizer().then((r)=>{updatedRandomizerName = r;});
        
        assert(intialRandomizerName == "oraclizer", "initial randomizer should be oraclize");
        assert(updatedRandomizerName == "blockHash", "updated randomizer should be blockHash");
    });
})

