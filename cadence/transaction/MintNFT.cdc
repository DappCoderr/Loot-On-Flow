import FungibleToken from "../contract/FungibleToken.cdc"
import NonFungibleToken from "../contract/NonFungibleToken.cdc"
import LootOnChain from "../contract/LootOnChain.cdc"
import FlowToken from "../contract/FlowToken.cdc"
import FUSD from "../contract/FUSD.cdc"


transaction(recipient: Address, nftIDs: UInt64) {

    // let receiverAddress: Address

    prepare(signer: AuthAccount) {

        // self.receiverAddress = signer.address

        //check collection is eixt or not
        // if signer.borrow<&LootOnChain.Collection>(from: LootOnChain.LootCollectionStoragePath) == nil {
        //     // create a new empty collection
        //     let collection <- LootOnChain.createEmptyCollection()
        //     // save it to the account
        //     signer.save(<-collection, to: LootOnChain.LootCollectionStoragePath)
        //     // create a public capability for the collection
        //     signer.link<&LootOnChain.Collection{NonFungibleToken.CollectionPublic, LootOnChain.LootOnChainPublicCollectiton}>(
        //     LootOnChain.LootCollectionPublicPath,
        //     target: LootOnChain.LootCollectionStoragePath
        //     )
        // }
    }

    execute {

        let recipient = getAccount(recipient)

        // borrow the recipient's public NFT collection reference
        let receiver = recipient
            .getCapability(LootOnChain.LootCollectionPublicPath)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // mint the NFT and deposit it to the recipient's collection
        LootOnChain.mintLoot( recipient: receiver, nftID: nftIDs)
    }
}