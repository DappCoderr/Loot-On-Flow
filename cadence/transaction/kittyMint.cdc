import NonFungibleToken from "../contract/NonFungibleToken.cdc"
import KittyItems from "../contract/KittyItems.cdc"

// This transction uses the NFTMinter resource to mint a new NFT.
//
// It must be run with the account that has the minter resource
// stored at path /storage/NFTMinter.
transaction(recipient: Address) {

    // local variable for storing the minter reference
    let minter: &KittyItems.NFTMinter

    prepare(signer: AuthAccount) {

        if signer.borrow<&KittyItems.Collection>(from: KittyItems.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- KittyItems.createEmptyCollection()
            
            // save it to the account
            signer.save(<-collection, to: KittyItems.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&KittyItems.Collection{NonFungibleToken.CollectionPublic, KittyItems.KittyItemsCollectionPublic}>(KittyItems.CollectionPublicPath, target: KittyItems.CollectionStoragePath)
        }

        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&KittyItems.NFTMinter>(from: KittyItems.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        // get the public account object for the recipient
        let recipient = getAccount(recipient)

        // borrow the recipient's public NFT collection reference
        let receiver = recipient
            .getCapability(KittyItems.CollectionPublicPath)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(
            recipient: receiver
        )
    }
}