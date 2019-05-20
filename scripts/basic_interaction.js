var fs = require('fs');

module.exports = function(callback) {
    // perform actions
    var jsonFile = "./build/contracts/KittyParty.json";
    var parsed= JSON.parse(fs.readFileSync(jsonFile));
    var abi = parsed.abi;
    //console.log(abi);



    var kpContract = new web3.eth.Contract(abi, '0x220870a17eE11b4b83eCa76Fdc0bB8aE517Ec2b9');
    kpContract.setProvider(new Web3.providers.HttpProvider("http://localhost:7545"));

    // var result;
    // kpContract.numberOfParticipants().then((r)=>{result=r});
    //console.log(kpContract.numberOfParticipants);
    console.log(kpContract);

    return;
  }