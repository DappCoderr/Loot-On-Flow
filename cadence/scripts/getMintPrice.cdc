import NonFungibleToken from "../contract/NonFungibleToken.cdc"
import LootOnChain from "../contract/LootOnChain.cdc"

// This script returns an array of all the NFT IDs in an account's collection.
pub fun main(): UFix64 {
    return LootOnChain.getMintPrice()
    // return collectionPrice
}