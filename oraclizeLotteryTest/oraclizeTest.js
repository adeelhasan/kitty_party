var KittyPartyLotteryOraclize = artifacts.require("./KittyPartyLotteryOraclize.sol");

function timeout(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}    

contract("KittyPartyLotteryOraclize", function(accounts){
    it("check the lotter should have expected number of results", async function(){

        let kplottery = await KittyPartyLotteryOraclize.deployed();

        //first, add some participants
        await web3.eth.sendTransaction({from: accounts[0], value: web3.utils.toWei('0.1','ether'), gas: 200000, to: kplottery.address});
        await web3.eth.sendTransaction({from: accounts[1], value: web3.utils.toWei('0.1','ether'), gas: 200000, to: kplottery.address});
        await web3.eth.sendTransaction({from: accounts[2], value: web3.utils.toWei('0.1','ether'), gas: 200000, to: kplottery.address});
        await web3.eth.sendTransaction({from: accounts[3], value: web3.utils.toWei('0.1','ether'), gas: 200000, to: kplottery.address});
        await web3.eth.sendTransaction({from: accounts[4], value: web3.utils.toWei('0.1','ether'), gas: 200000, to: kplottery.address});

        await kplottery.closeParticipants();

        let numberOfParticipants = await kplottery.numberOfParticipants();
        assert(numberOfParticipants == 5, "5 participants");

        let winnersOrderArrayLength = await kplottery.orderOfWinnersLength(); //should be 0 length
        assert(winnersOrderArrayLength == 0, "no ordering yet");

        //this will trigger the Oraclizer, which will be heard back from with a delay
        await kplottery.doInitialLottery();

        await timeout(20000);

        winnersOrderArrayLength = await kplottery.orderOfWinnersLength(); //see if populated now
        if (winnersOrderArrayLength == 0){
            await timeout(20000);   //not populated, so wait some more
        }
        winnersOrderArrayLength = await kplottery.orderOfWinnersLength(); //this is as much we are going to wait

        assert(Math.abs(winnersOrderArrayLength-numberOfParticipants)==0, "should have selected an ordering as many as the participants");

    });

    it("closing the first cycle, should let the first randomly select participant win, and collect the kitty", async function(){
        let kplottery = await KittyPartyLotteryUpgradable.deployed();

        var expectedCycleWinner;
        kplottery.winnerAt(0).then((r)=>{expectedCycleWinner=r;});
        var result = await kplottery.completeCycle();
        var actualWinner = result.logs[0].args.winner;

        var orderOfWinners = await kplottery.enumerateOrderOfWinners();
        function writeOutBN(item,index) {
            console.log(item.toNumber());
        }
        orderOfWinners.forEach(writeOutBN);

        console.log(accounts);
        console.log(expectedCycleWinner);
        console.log(actualWinner);

        assert(expectedCycleWinner==actualWinner,"The expected winner");

        let winnerBalanceBefore = await web3.eth.getBalance(actualWinner);
        await kpac.withdrawMyWinnings({from: expectedCycleWinner});

        let winnerBalanceAfter = await web3.eth.getBalance(actualWinner);
        assert(Math.abs(winnerBalanceAfter - winnerBalanceBefore) > 0, "kitty amount went to the winner");
    });

})
