### Flow contract deploy
flow project deploy --network testnet

### Flow contract update 
flow project deploy --network testnet --update

### Transaction to Mint the Loot
flow transactions send ./cadence/transaction/MintNFT.cdc --network testnet --signer v 0x4f7babd3f2e52b

### Script to check to Loot in collection 
flow scripts execute ./cadence/scripts/getID.cdc --network=testnet 0x4f7babd3f2e52b7f