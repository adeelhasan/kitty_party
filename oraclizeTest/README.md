## Testing Oraclize

The oraclize service is used in [KittyPartyLotteryOraclize.sol](contracts/KittyPartyLotterOraclize.sol) to provided random array indices.

The [Ethereum Bridge] allows testing oraclize locally, which is very handy.

1. To install :

```
npm install -g ethereum-bridge
```

2. Make sure your local chain is running on localhost:8545; the bridge deploys contracts to the chain passed in its startup parameters

3. in a new terminal, navigate to the kitty party folder, there is a script all set :

```
npm run brdige
```

This basically starts the bridge with the correct parameters. It can take a little time for the bridge to fully boot up, you will need to wait for that. When you see "(Ctrl+C to exit)" it would be ready.

4. from another terminal, go to the main kitty party folder, and run the test :

```
truffle test .\oraclizeTest\oraclizeTest.js
```

 - you should see activity in the terminal with the bridge running in it
 - also note that the test thread sleeps for 20 seconds to give enough time for oraclize to run __callabck

[Ethereum Bridge]: https://github.com/oraclize/ethereum-bridge