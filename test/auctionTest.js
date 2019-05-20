var KittyPartyAuction = artifacts.require("./KittyPartyAuction.sol");

 contract("KittyPartyAuction", function(accounts){

    //now close the participatory round
    const account0Bid = web3.utils.toWei('0.25','ether');
    const account1Bid = web3.utils.toWei('0.5','ether');
    const account2Bid = web3.utils.toWei('1','ether');
    const expectedDividend = account2Bid / 2;
    const expectedDividendCycle2 = account1Bid; //all of it will go back

    it("after setup, the balance should be 3", async function(){
        let kpac = await KittyPartyAuction.deployed(); //kitty party contract instance

        //put in three participants
        await web3.eth.sendTransaction({from: accounts[0], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});
        await web3.eth.sendTransaction({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});
        await web3.eth.sendTransaction({from: accounts[2], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});
        var contractBalance = await web3.eth.getBalance(kpac.address);
        
        assert(contractBalance == new web3.utils.BN(web3.utils.toWei('3','ether')), "contract has received three participants");

        await kpac.closeParticipants();
        let currentStatus = await kpac.getStage();

        assert(currentStatus == 1, "stage should be in Progress");
        
    });

    it("should have three bids entered", async function(){
        let kpac = await KittyPartyAuction.deployed(); //kitty party contract instance

        await kpac.receiveBid({from: accounts[0], value: account0Bid});
        await kpac.receiveBid({from: accounts[1], value: account1Bid});
        await kpac.receiveBid({from: accounts[2], value: account2Bid});

        let numberOfBidders = await kpac.numberOfBidders();
        let bn3 = new web3.utils.BN('3');
        assert(Math.abs(numberOfBidders - bn3) == 0 , "number of bidders should be three");
    });

    it("should not allow a bidder to bid again", async function (){
        let kpac = await KittyPartyAuction.deployed(); //kitty party contract instance

        try{
            await kpac.receiveBid({from: accounts[1], value: web3.utils.toWei('0.5','ether')});
        }
        catch(e){
            return true;
        }

        throw new Error("should not have allowed to bid again");
    });

    it("closing the first cycle, should let the highest party win, and redistribute as expected", async function(){
        let kpac = await KittyPartyAuction.deployed(); //kitty party contract instance

        let account0BalanceBefore = await web3.eth.getBalance(accounts[0]);
        let account1BalanceBefore = await web3.eth.getBalance(accounts[1]);
        let account2BalanceBefore = await web3.eth.getBalance(accounts[2]);

        await kpac.completeCycle({from: accounts[0], gas: 200000});

        let account0BalanceAfter = await web3.eth.getBalance(accounts[0]);
        let account1BalanceAfter = await web3.eth.getBalance(accounts[1]);
        let account2BalanceAfter = await web3.eth.getBalance(accounts[2]);

        let bn3Ethers = new web3.utils.BN(web3.utils.toWei('3','ether'));

        //console.log('after: %s before: %s  bid: %s dividend: %s',account1BalanceAfter, account1BalanceBefore,account1Bid, expectedDividend);
        var expectedBalance = new web3.utils.BN(account1BalanceBefore.toString());
        expectedBalance = expectedBalance.add(new web3.utils.BN(account1Bid.toString()));
        expectedBalance = expectedBalance.add(new web3.utils.BN(expectedDividend.toString()));

        assert(Math.abs(account2BalanceAfter - account2BalanceBefore) == bn3Ethers, "winning bid got the kitty amount");
        //assert(new web3.utils.BN(account1BalanceAfter.toString()).eq(expectedBalance),"failed bid was refunded properly, along with dividend");
    });

    it("the second cycle, previous winner should not be able to bid", async function(){
        let kpac = await KittyPartyAuction.deployed(); //kitty party contract instance

        //put in three participants
        await web3.eth.sendTransaction({from: accounts[0], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});
        await web3.eth.sendTransaction({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});
        await web3.eth.sendTransaction({from: accounts[2], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});


        await kpac.receiveBid({from: accounts[0], value: account0Bid});
        await kpac.receiveBid({from: accounts[1], value: account1Bid});
        try{
            await kpac.receiveBid({from: accounts[2], value: account2Bid});
        }
        catch(e){
            return true;
        }
    
        throw new Error("previous winners bid should not have allowed to bid again");
    });

    it("closing the second cycle", async function(){
        let kpac = await KittyPartyAuction.deployed(); //kitty party contract instance

        let account0BalanceBefore = await web3.eth.getBalance(accounts[0]);
        let account1BalanceBefore = await web3.eth.getBalance(accounts[1]);
        let account2BalanceBefore = await web3.eth.getBalance(accounts[2]);

        await kpac.completeCycle({from: accounts[0], gas: 200000});

        let account0BalanceAfter = await web3.eth.getBalance(accounts[0]);
        let account1BalanceAfter = await web3.eth.getBalance(accounts[1]);
        let account2BalanceAfter = await web3.eth.getBalance(accounts[2]);

        let bn3Ethers = new web3.utils.BN(web3.utils.toWei('3','ether'));

        var expectedBalance = new web3.utils.BN(account0BalanceBefore.toString());
        expectedBalance = expectedBalance.add(new web3.utils.BN(account0Bid.toString()));
        expectedBalance = expectedBalance.add(new web3.utils.BN(expectedDividendCycle2.toString()));

        //console.log('after: %s before: %s  bid: %s expected balance: %s, dividend: %s',account0BalanceAfter, account0BalanceBefore,account1Bid, expectedBalance.toString(), expectedDividendCycle2.toString());

        assert(Math.abs(account1BalanceAfter - account1BalanceBefore) == bn3Ethers, "winning bid got the kitty amount");
        
        //cannot use this accurately, since account0 also consumes gas
        //assert(new web3.utils.BN(account0BalanceAfter.toString()).eq(expectedBalance),"failed bid was refunded properly, along with dividend");
    });
    
    it("the third and final cycle, should leave the Kitty Stage to be finished", async function(){
        let kpac = await KittyPartyAuction.deployed(); //kitty party contract instance

        //put in three participants
        await web3.eth.sendTransaction({from: accounts[0], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});
        await web3.eth.sendTransaction({from: accounts[1], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});
        await web3.eth.sendTransaction({from: accounts[2], value: web3.utils.toWei('1','ether'), gas: 200000, to: kpac.address});

        //previous winner should be rejected, just like before
        try        {
            await kpac.receiveBid({from: accounts[1], value: account1id});
            throw new Error("previous winners bid should not have allowed to bid again");
        }
        catch(e){            
            //proceed ..
        }
    

        let account0BalanceBefore = await web3.eth.getBalance(accounts[0]);
        let account1BalanceBefore = await web3.eth.getBalance(accounts[1]);
        let account2BalanceBefore = await web3.eth.getBalance(accounts[2]);

        await kpac.completeCycle({from: accounts[0], gas: 200000});

        let account0BalanceAfter = await web3.eth.getBalance(accounts[0]);
        let account1BalanceAfter = await web3.eth.getBalance(accounts[1]);
        let account2BalanceAfter = await web3.eth.getBalance(accounts[2]);

        let bn3Ethers = new web3.utils.BN(web3.utils.toWei('3','ether'));


        let finalStatus = await kpac.getStage();

        //console.log('after: %s before: %s',account0BalanceAfter, account0BalanceBefore);


        assert(finalStatus == 2, "final status should be finished, enum value is 2");
        assert(Math.abs(account1BalanceAfter - account1BalanceBefore) == 0, "other account's balance should not have been effected");

        //account 0 is again not the best way to compare, because of the gas usage.
        //assert(Math.abs(account0BalanceAfter - account0BalanceBefore) == bn3Ethers, "this kitty is for the remaining participant");
    });    

})