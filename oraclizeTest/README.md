## Testing Oraclize

The oraclize service is used in [KittyPartyLotteryOraclize.sol](contracts/KittyPartyLotterOraclize.sol) to provided random array indices.

The [Ethereum Bridge] allows testing oraclize locally, which is very handy.

1. To install :

```
npm install -g ethereum-bridge
```

2. Make sure your local chain is running on localhost:8545

3. in a new terminal, navigate to the root folder in the kitty party folder, there is a script all set :

```
npm run brdige
```

This basically starts the bridge with the correct parameters. It can take a little time for the bridge to fully boot up, you will need to wait for that.

4. run the test :

```
truffle test .\oraclizeTest\oraclizeTest.js
```

you should see activity in the terminal with the bridge running in it

[Ethereum Bridge]: https://github.com/oraclize/ethereum-bridge