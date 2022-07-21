import FungibleToken from "../contract/FungibleToken.cdc"
import NonFungibleToken from "../contract/NonFungibleToken.cdc"
import LootOnChain from "../contract/LootOnChain.cdc"
import FlowToken from "../contract/FlowToken.cdc"
import FUSD from "../contract/FUSD.cdc"


transaction(recipient: Address) {


    let minter: &LootOnChain.NFTMinter

    prepare(signer: AuthAccount) {

        if signer.borrow<&LootOnChain.Collection>(from: LootOnChain.LootCollectionStoragePath) == nil {
            let collection <- LootOnChain.createEmptyCollection()
            signer.save(<-collection, to: LootOnChain.LootCollectionStoragePath)
            signer.link<&LootOnChain.Collection{NonFungibleToken.CollectionPublic, LootOnChain.LootOnChainPublicCollectiton}>(LootOnChain.LootCollectionPublicPath, target: LootOnChain.LootCollectionStoragePath)
        }

        self.minter = signer.borrow<&LootOnChain.NFTMinter>(from: LootOnChain.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        
        let recipient = getAccount(recipient)

        let receiver = recipient
            .getCapability(LootOnChain.LootCollectionPublicPath)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        self.minter.mintNFT(recipient: receiver)
    }
}

// transaction(recipient: Address) {

//     // let receiverAddress: Address

//     prepare(signer: AuthAccount) {

//         // self.receiverAddress = signer.address

//         //check collection is eixt or not
//         // if signer.borrow<&LootOnChain.Collection>(from: LootOnChain.LootCollectionStoragePath) == nil {
//         //     // create a new empty collection
//         //     let collection <- LootOnChain.createEmptyCollection()
//         //     // save it to the account
//         //     signer.save(<-collection, to: LootOnChain.LootCollectionStoragePath)
//         //     // create a public capability for the collection
//         //     signer.link<&LootOnChain.Collection{NonFungibleToken.CollectionPublic, LootOnChain.LootOnChainPublicCollectiton}>(
//         //     LootOnChain.LootCollectionPublicPath,
//         //     target: LootOnChain.LootCollectionStoragePath
//         //     )
//         // }
//     }

//     execute {

//         let recipients = getAccount(recipient)

//         // borrow the recipient's public NFT collection reference
//         let receiver = recipients
//             .getCapability(LootOnChain.LootCollectionPublicPath)!
//             .borrow<&{NonFungibleToken.CollectionPublic}>()
//             ?? panic("Could not get receiver reference to the NFT Collection")

//         // mint the NFT and deposit it to the recipient's collection
//         LootOnChain.mintLoot(recipient: receiver)
//     }

 