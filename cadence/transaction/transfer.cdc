import NonFungibleToken from 0x1d7e57aa55817448
    import PartyMansionDrinksContract from 0x34f2bf4a80bb0f69
    
    transaction(drinkID: UInt64, receiverAddress: Address) {
      // local variable for storing the minter reference
    
      let receiverReference: &{NonFungibleToken.CollectionPublic}
      let receiverAddress: Address
      let collection: &PartyMansionDrinksContract.Collection
    
      prepare(acct: AuthAccount) {
        // borrow collection
        self.collection = acct.borrow<&PartyMansionDrinksContract.Collection>(from: PartyMansionDrinksContract.CollectionStoragePath)!
        
        self.receiverAddress = receiverAddress
        // borrow the recipient''s public NFT collection reference
        self.receiverReference = getAccount(self.receiverAddress)
                .getCapability(PartyMansionDrinksContract.CollectionPublicPath)!
                .borrow<&{NonFungibleToken.CollectionPublic}>()
                ?? panic("Could not get receiver reference to the NFT Collection")
      }
    
      execute {
        self.receiverReference.deposit(token: <-self.collection.withdraw(withdrawID: drinkID))
      }
    }