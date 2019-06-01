var KittyPartyLotteryOraclize = artifacts.require("./KittyPartyLotteryOraclize.sol");

function timeout(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}    

contract("KittyPartyLotteryOraclize", function(accounts){
    it("check the lottery should have expected number of results", async function(){

        let kplottery = await KittyPartyLotteryOraclize.deployed();

        //first, add some participants
        await web3.eth.sendTransaction({from: accounts[0], value: web3.utils.toWei('1.0','ether'), gas: 200000, to: kplottery.address});
        await web3.eth.sendTransaction({from: accounts[1], value: web3.utils.toWei('1.0','ether'), gas: 200000, to: kplottery.address});
        await web3.eth.sendTransaction({from: accounts[2], value: web3.utils.toWei('1.0','ether'), gas: 200000, to: kplottery.address});
        await web3.eth.sendTransaction({from: accounts[3], value: web3.utils.toWei('1.0','ether'), gas: 200000, to: kplottery.address});
        await web3.eth.sendTransaction({from: accounts[4], value: web3.utils.toWei('1.0','ether'), gas: 200000, to: kplottery.address});

        await kplottery.closeParticipants();

        let numberOfParticipants = await kplottery.numberOfParticipants();
        assert(numberOfParticipants == 5, "5 participants");

        let winnersOrderArrayLength = await kplottery.orderOfWinnersLength(); //should be 0 length
        assert(winnersOrderArrayLength == 0, "no ordering yet");

        //additional value is sent, since the oraclizer will deduct from the contracts balance
        //in so doing, unless additional value is sent, the standing funds would otherwise get usurped
        //this is being sent from the default account, but it should really be refunded back to that account
        //by the account that will win that particular cycle
        var gasToSend = 500000; //unused gas is not refunded by Oraclize
        var gasPrice = web3.eth.toWei('20','gWei');
        var additional_value_to_send = gasToSend * gasPrice;
        await kplottery.initialLottery({value: additional_value_to_send});

        // 2 or three transaction confirmations are needed here
        // best to wait for the event
        await timeout(30000);

        winnersOrderArrayLength = await kplottery.orderOfWinnersLength(); //see if populated now
        if (winnersOrderArrayLength == 0){
            await timeout(20000);   //not populated, so wait some more
        }
        winnersOrderArrayLength = await kplottery.orderOfWinnersLength(); //this is as much we are going to wait

        assert(Math.abs(winnersOrderArrayLength-numberOfParticipants)==0, "should have selected an ordering as many as the participants");

    });

    it("closing the first cycle, should let the first randomly select participant win, and collect the kitty", async function(){
        let kplottery = await KittyPartyLotteryOraclize.deployed();

        var expectedCycleWinner = await kplottery.winnerAt(0);

        var result = await kplottery.completeCycle();
        var actualWinner = result.logs[0].args.winner;

        assert(expectedCycleWinner==actualWinner,"The expected winner");

        let winnerBalanceBefore = await web3.eth.getBalance(actualWinner);
        await kplottery.withdrawMyWinnings({from: expectedCycleWinner});
        let winnerBalanceAfter2 = await web3.eth.getBalance(actualWinner);

        assert(Math.abs(winnerBalanceAfter2 - winnerBalanceBefore) > 0, "kitty amount went to the winner");
    });

})
