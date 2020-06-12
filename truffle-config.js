const HDWalletProvider = require('@truffle/hdwallet-provider');
const infuraKey = "1061d5f5bcaf4b518db09da8c2a47f09";

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
  networks: {
    development: {
     host: "127.0.0.1",
     port: 7545,
     network_id: "*"
    },
    
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(
          mnemonic,
          "https://rinkeby.infura.io/v3/" + infuraKey
        )
      },
      network_id: "*",
      gas: 4000000
    },
  },

  compilers: {
    solc: {
      version: "0.4.26"
    }
  }
}
