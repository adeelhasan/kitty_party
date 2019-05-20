
var KittyPartySequential = artifacts.require("./KittyPartySequential.sol");

contract("KittyPartySequential", function(accounts){
    var kps; //kitty party contract instance

    it("after setup, the balance should be 3", async function(){
        let kps = await KittyPartySequential.deployed(); //kitty party contract instance

        //put in three participants
        await web3.eth.sendTransaction({from: accounts[0], value: web3.utils.toWei('1','ether'), gas: 200000, to: kps.address});
        await web3.eth.sendTransaction({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000, to: kps.address});
        await web3.eth.sendTransaction({from: accounts[2], value: web3.utils.toWei('1','ether'), gas: 200000, to: kps.address});
        var contractBalance = await web3.eth.getBalance(kps.address);
        
        assert(contractBalance == new web3.utils.BN(web3.utils.toWei('3','ether')), "contract has received three participants");
    });

    it("sending the incorrect amount should get rejected", async function(){
        let kps = await KittyPartySequential.deployed(); //kitty party contract instance

        try{
            await web3.eth.sendTransaction({from: accounts[3], value: web3.utils.toWei('0.5','ether'), gas: 200000, to: kps.address});
        }
        catch(e){
            return true;
        }

        assert(false, "should not have come here");
    });

    it("after closing the kitty to participants, the stage should be in progress", async function(){
        let kps = await KittyPartySequential.deployed(); //kitty party contract instance

        await kps.closeParticipants();
        let currentStatus = await kps.getStage();

        assert(currentStatus == 1, "stage should be in Progress");
    });

    it("once in progress, should not allow another new participant", async function(){
        let kps = await KittyPartySequential.deployed(); //kitty party contract instance

        try{
            await web3.eth.sendTransaction({from: accounts[3], value: web3.utils.toWei('1','ether'), gas: 200000, to: kps.address});
        }
        catch(e){
            return true;
        }

        throw new Error("should not have allowed to add another participant");
    });

    it("setting a circuit breaker emergency should reject any contributions to the kitty", async function(){
        let kps = await KittyPartySequential.deployed();

        await kps.setCircuitBreakerToStopped();

        try{
            await web3.eth.sendTransaction({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000, to: kps.address});
        }
        catch(e){
            return true;
        }

        throw new Error("should not have allowed a contribution during an emergency");
    });

    it("non owner account should not be able to open the emergency", async function(){
        let kps = await KittyPartySequential.deployed();

        try{
            await kps.setCircuitBreakerEmergencyFinished({from: accounts[1]});
        }
        catch(e){

            //finish the emergency mode so that we can continue
            await kps.setCircuitBreakerEmergencyFinished({from: accounts[0]});

            return true;
        }

        throw new Error("should have failed when lifting up the emergency");
    });

    it("closing the first cycle, should let the first participant win, and collect the kitty", async function(){
        let kpac = await KittyPartySequential.deployed(); //kitty party contract instance

        let account0BalanceBefore = await web3.eth.getBalance(accounts[0]);
        let account1BalanceBefore = await web3.eth.getBalance(accounts[1]);
        let account2BalanceBefore = await web3.eth.getBalance(accounts[2]);

        await kpac.completeCycle({from: accounts[0], gas: 200000});

        let account0BalanceAfter = await web3.eth.getBalance(accounts[0]);
        let account1BalanceAfter = await web3.eth.getBalance(accounts[1]);
        let account2BalanceAfter = await web3.eth.getBalance(accounts[2]);

        //the delta should have been 3 ether, but since accounts[0] expends gas, we approximate
        let expectedBalanceDelta = new web3.utils.BN(web3.utils.toWei('2.8','ether'))

        assert(Math.abs(account0BalanceAfter - account0BalanceBefore) > expectedBalanceDelta, "kitty amount went to first account");
        assert(Math.abs(account2BalanceAfter - account2BalanceBefore) == 0, "kitty amount didnt go to second one");
        assert(Math.abs(account1BalanceAfter - account1BalanceBefore) == 0, "kitty amount didnt go to third one");
    });

    it("closing the second and third cycles should finish the kitty", async function(){
        let kpac = await KittyPartySequential.deployed(); //kitty party contract instance

        let account0BalanceBefore = await web3.eth.getBalance(accounts[0]);
        let account1BalanceBefore = await web3.eth.getBalance(accounts[1]);
        let account2BalanceBefore = await web3.eth.getBalance(accounts[2]);

        //second cycle
        await web3.eth.sendTransaction({from: accounts[0], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});
        await web3.eth.sendTransaction({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});
        await web3.eth.sendTransaction({from: accounts[2], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});

        await kpac.completeCycle({from: accounts[0], gas: 200000});

        //third cycle
        await web3.eth.sendTransaction({from: accounts[0], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});
        await web3.eth.sendTransaction({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});
        await web3.eth.sendTransaction({from: accounts[2], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});

        await kpac.completeCycle({from: accounts[0], gas: 200000});

        let account0BalanceAfter = await web3.eth.getBalance(accounts[0]);
        let account1BalanceAfter = await web3.eth.getBalance(accounts[1]);
        let account2BalanceAfter = await web3.eth.getBalance(accounts[2]);

        let expectedBalanceDelta = new web3.utils.BN(web3.utils.toWei('0.9','ether'))
        //console.log('after: %s before: %s  bid: %s expected balance: %s',account2BalanceAfter, account2BalanceBefore,expectedBalanceDelta.toString(),0);


        assert(Math.abs(account2BalanceAfter - account2BalanceBefore) > expectedBalanceDelta, "the ether came back to accounts[2]");
        assert(Math.abs(account1BalanceAfter - account1BalanceBefore) > expectedBalanceDelta, "the ether came back to accounts[1]");

        let currentStatus = await kpac.getStage();

        assert(currentStatus == 2, "stage should be finished");
    });

})

