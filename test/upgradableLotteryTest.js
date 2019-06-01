
var KittyPartyLotteryUpgradable = artifacts.require("./KittyPartyLotteryUpgradable.sol");
var OraclizeRandomizer = artifacts.require("./OraclizeRandomizer.sol");
var BlockRandomizer = artifacts.require("./BlockRandomizer.sol");


contract("KittyPartyLotteryUpgradable", function(accounts){

    let kittyContract;
    beforeEach(async function () {
        kittyContract = await KittyPartyLotteryUpgradable.deployed();         
      });

    it("should be able to switch the randomizer", async function() {

        let oraclizeRandomizer = await OraclizeRandomizer.deployed();
        let blockRandomizer = await BlockRandomizer.deployed();

        var intialRandomizerName, updatedRandomizerName;

        //the initial randomizer is set in the deployment script
        await kittyContract.getTypeOfRandomizer().then((r)=>{intialRandomizerName = r;});
        await kittyContract.updateRandomizer(blockRandomizer.address);
        await kittyContract.getTypeOfRandomizer().then((r)=>{updatedRandomizerName = r;});

        assert(intialRandomizerName == "oraclizer", "initial randomizer should be oraclize");
        assert(updatedRandomizerName == "blockHash", "updated randomizer should be blockHash");
    });

    it("should be able to do the initial lottery and fill up the storage", async function(){
        //first, add some participants
        await kittyContract.addParticipant({from: accounts[0], value: web3.utils.toWei('1','ether'), gas: 200000});
        await kittyContract.addParticipant({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000});
        await kittyContract.addParticipant({from: accounts[2], value: web3.utils.toWei('1','ether'), gas: 200000});
        await kittyContract.addParticipant({from: accounts[3], value: web3.utils.toWei('1','ether'), gas: 200000});
        await kittyContract.addParticipant({from: accounts[4], value: web3.utils.toWei('1','ether'), gas: 200000});

        await kittyContract.closeParticipants();
        let numberOfParticipants = await kittyContract.numberOfParticipants();
        assert(numberOfParticipants == 5, "5 participants");

        let winnersOrderArrayLength = await kittyContract.orderOfWinnersLength(); //should be 0 length
        assert(winnersOrderArrayLength == 0, "no ordering yet");

        await kittyContract.initialLottery();
        winnersOrderArrayLength = await kittyContract.orderOfWinnersLength(); //should be populated now

        assert(Math.abs(winnersOrderArrayLength-numberOfParticipants)==0, "should have selected an ordering as many as the participants");
    });

    it("the first randomly selected winner was the one who won the first round", async function(){
        var expectedCycleWinner;
        kittyContract.winnerAt(0).then((r)=>{expectedCycleWinner=r;});
        var result = await kittyContract.completeCycle();
        var actualWinner = result.logs[0].args.winner;

        assert(expectedCycleWinner==actualWinner,"The expected winner");
    });
})

