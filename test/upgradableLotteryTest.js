
var KittyPartyLotteryUpgradable = artifacts.require("./KittyPartyLotteryUpgradable.sol");
var OraclizeRandomizer = artifacts.require("./OraclizeRandomizer.sol");
var BlockRandomizer = artifacts.require("./BlockRandomizer.sol");


contract("KittyPartyLotteryUpgradable", function(accounts){
    it("should be able to switch the randomizer", async function() {

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

    it("should be able to do the initial lottery and fill up the storage", async function(){
        let kplottery = await KittyPartyLotteryUpgradable.deployed();

        //first, add some participants
        await web3.eth.sendTransaction({from: accounts[0], value: web3.utils.toWei('1','ether'), gas: 200000, to: kplottery.address});
        await web3.eth.sendTransaction({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000, to: kplottery.address});
        await web3.eth.sendTransaction({from: accounts[2], value: web3.utils.toWei('1','ether'), gas: 200000, to: kplottery.address});
        await web3.eth.sendTransaction({from: accounts[3], value: web3.utils.toWei('1','ether'), gas: 200000, to: kplottery.address});
        await web3.eth.sendTransaction({from: accounts[4], value: web3.utils.toWei('1','ether'), gas: 200000, to: kplottery.address});

        //the initial randomizer is set in the deployment script
        await kplottery.closeParticipants();
        let numberOfParticipants = await kplottery.numberOfParticipants();
        assert(numberOfParticipants == 5, "5 participants");

        let winnersOrderArrayLength = await kplottery.orderOfWinnersLength(); //should be 0 length
        assert(winnersOrderArrayLength == 0, "no ordering yet");

        await kplottery.initialLottery();
        winnersOrderArrayLength = await kplottery.orderOfWinnersLength(); //should be populated now

        assert(Math.abs(winnersOrderArrayLength-numberOfParticipants)==0, "should have selected an ordering as many as the participants");
    });
})

