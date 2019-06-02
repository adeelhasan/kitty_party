
var KittyPartySequential = artifacts.require("./KittyPartySequential.sol");

contract("KittyPartySequential", function(accounts){

    let kittyContract;
    beforeEach(async function () {
        kittyContract = await KittyPartySequential.deployed();         
      });
    
    it("after setup, the balance should be 3", async function(){
        //put in three participants
        await kittyContract.addParticipant({from: accounts[0], value: web3.utils.toWei('1','ether'), gas: 200000});
        await kittyContract.addParticipant({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000});
        await kittyContract.addParticipant({from: accounts[2], value: web3.utils.toWei('1','ether'), gas: 200000});
        var contractBalance = await web3.eth.getBalance(kittyContract.address);
        
        assert(contractBalance == new web3.utils.BN(web3.utils.toWei('3','ether')), "contract has received three participants");
    });

    it("sending the incorrect amount should get rejected", async function(){

        try{
            await kittyContract.addParticipant({from: accounts[3], value: web3.utils.toWei('0.5','ether'), gas: 200000});
        }
        catch(e){
            return true;
        }

        assert(false, "should not have come here");
    });

    it("after closing the kitty to participants, the stage should be Started", async function(){
        await kittyContract.closeParticipants();
        let currentStatus = await kittyContract.getStage();

        assert(currentStatus == 1, "stage should be Started");
    });

    it("once in progress, should not allow another new participant", async function(){
        try{
            await kittyContract.addParticipant({from: accounts[3], value: web3.utils.toWei('1','ether'), gas: 200000});
        }
        catch(e){
            return true;
        }

        throw new Error("should not have allowed to add another participant");
    });

    it("setting a circuit breaker emergency should reject any contributions to the kitty", async function(){
        await kittyContract.setCircuitBreakerToStopped();

        try{
            await web3.eth.sendTransaction({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000, to: kittyContract.address});
        }
        catch(e){
            return true;
        }

        throw new Error("should not have allowed a contribution during an emergency");
    });

    it("non owner account should not be able to open the emergency", async function(){
        try{
            await kittyContract.setCircuitBreakerEmergencyFinished({from: accounts[1]});
        }
        catch(e){

            //finish the emergency mode so that we can continue
            await kittyContract.setCircuitBreakerEmergencyFinished({from: accounts[0]});

            return true;
        }

        throw new Error("should have failed when lifting up the emergency");
    });

    it("closing the first cycle, should let the first participant win, and collect the kitty", async function(){
        var result = await kittyContract.completeCycle({from: accounts[0], gas: 200000});
        var winnerAddress = result.logs[0].args.winner;

        assert(accounts[0] == winnerAddress, "The first participant won the first cycle");
    });

    it("the winner of the first cycle can collect the kitty", async function() {
        let account0BalanceBefore = await web3.eth.getBalance(accounts[0]);
        await kittyContract.withdrawMyWinnings({from: accounts[0]});
        let account0BalanceAfter = await web3.eth.getBalance(accounts[0]);

        //the delta should have been 3 ether, but since accounts[0] expends gas, we approximate
        let expectedBalanceDelta = new web3.utils.BN(web3.utils.toWei('2.8','ether'))

        assert(Math.abs(account0BalanceAfter - account0BalanceBefore) > expectedBalanceDelta, "kitty amount went to first account");
    });


    it("closing the second and third cycles should finish the kitty", async function() {
        let account0BalanceBefore = await web3.eth.getBalance(accounts[0]);
        let account1BalanceBefore = await web3.eth.getBalance(accounts[1]);
        let account2BalanceBefore = await web3.eth.getBalance(accounts[2]);

        //second cycle
        await kittyContract.addParticipant({from: accounts[0], value: web3.utils.toWei('1','ether'), gas: 200000});
        await kittyContract.addParticipant({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000});
        await kittyContract.addParticipant({from: accounts[2], value: web3.utils.toWei('1','ether'), gas: 200000});

        await kittyContract.completeCycle({from: accounts[0], gas: 200000});
        await kittyContract.withdrawMyWinnings({from: accounts[1]});

        //third cycle
        await kittyContract.addParticipant({from: accounts[0], value: web3.utils.toWei('1','ether'), gas: 200000});
        await kittyContract.addParticipant({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000});
        await kittyContract.addParticipant({from: accounts[2], value: web3.utils.toWei('1','ether'), gas: 200000});

        await kittyContract.completeCycle({from: accounts[0], gas: 200000});
        await kittyContract.withdrawMyWinnings({from: accounts[2]});

        let account0BalanceAfter = await web3.eth.getBalance(accounts[0]);
        let account1BalanceAfter = await web3.eth.getBalance(accounts[1]);
        let account2BalanceAfter = await web3.eth.getBalance(accounts[2]);

        let expectedBalanceDelta = new web3.utils.BN(web3.utils.toWei('0.9','ether'))
        //console.log('after: %s before: %s  bid: %s expected balance: %s',account2BalanceAfter, account2BalanceBefore,expectedBalanceDelta.toString(),0);


        assert(Math.abs(account2BalanceAfter - account2BalanceBefore) > expectedBalanceDelta, "the ether came back to accounts[2]");
        assert(Math.abs(account1BalanceAfter - account1BalanceBefore) > expectedBalanceDelta, "the ether came back to accounts[1]");

        let currentStatus = await kittyContract.getStage();

        assert(currentStatus == 2, "stage should be finished");
    });

})

