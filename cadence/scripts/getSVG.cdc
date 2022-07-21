import NonFungibleToken from "../contract/NonFungibleToken.cdc"
import LootOnChain from "../contract/LootOnChain.cdc"

pub fun main(): String {
    return LootOnChain.generateSVG()
}