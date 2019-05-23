var KittyPartyLotteryOraclize = artifacts.require("./KittyPartyLotteryOraclize.sol");

contract("KittyPartyLotteryOraclize", function(accounts){
    it("should be able to switch the randomizer", async function(){

        let networkID = (await this.promisify(web3.currentProvider.sendAsync, {
            jsonrpc: "2.0",
            method: "net_version",
            params: [],
            id: 0
        })).result;

        if (networkID == "3")
        {
            let kplottery = await KittyPartyLotteryOraclize.deployed();

            //first, add some participants
            await web3.eth.sendTransaction({from: accounts[0], value: web3.utils.toWei('1','ether'), gas: 200000, to: kplottery.address});
            await web3.eth.sendTransaction({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000, to: kplottery.address});
            await web3.eth.sendTransaction({from: accounts[2], value: web3.utils.toWei('1','ether'), gas: 200000, to: kplottery.address});
            await web3.eth.sendTransaction({from: accounts[3], value: web3.utils.toWei('1','ether'), gas: 200000, to: kplottery.address});
            await web3.eth.sendTransaction({from: accounts[4], value: web3.utils.toWei('1','ether'), gas: 200000, to: kplottery.address});
            await kplottery.closeParticipants();

            let numberOfParticipants = await kplottery.numberOfParticipants();
            assert(numberOfParticipants == 5, "5 participants");

            let winnersOrderArrayLength = await kplottery.orderOfWinnersLength(); //should be 0 length
            assert(winnersOrderArrayLength == 0, "no ordering yet");

            //this will trigger the Oraclizer, which will be heard back from with a delay
            await kplottery.doInitialLottery();

            function timeout(ms) {
                return new Promise(resolve => setTimeout(resolve, ms));
            }    
            await timeout(20000);

            winnersOrderArrayLength = await kplottery.orderOfWinnersLength(); //see if populated now
            if (winnersOrderArrayLength == 0){
                await timeout(20000);   //not populated, so wait some more
            }
            winnersOrderArrayLength = await kplottery.orderOfWinnersLength(); //this is as much we are going to wait

            assert(Math.abs(winnersOrderArrayLength-numberOfParticipants)==0, "should have selected an ordering as many as the participants");
        }
        else
            return false;
    });
})
