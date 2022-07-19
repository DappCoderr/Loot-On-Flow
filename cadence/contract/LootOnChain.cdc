import NonFungibleToken from "./NonFungibleToken.cdc"
import FungibleToken from "./FungibleToken.cdc"
import FlowToken from "./FlowToken.cdc"
// import FUSD from "./FUSD.cdc"

pub contract LootOnChain: NonFungibleToken {

    pub let LootCollectionStoragePath: StoragePath
    pub let LootCollectionPublicPath: PublicPath

    access(self) let idToAddress: [Address]

    pub let weapons: [String] 
    pub let chestArmor: [String] 
    pub let headArmor: [String] 

    pub let maxSupply: UInt64
    pub var totalSupply: UInt64
    pub var part1: String
    pub var part2: String
    pub var part3: String

    pub let flowStorageFeePerHaiku: UFix64
    pub var price: UFix64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id:UInt64)


    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64
        init(id:UInt64){
            self.id = id;
        }
    }

    pub resource interface LootOnChainPublicCollectiton{
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    } 

    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, LootOnChainPublicCollectiton {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init(){
            self.ownedNFTs <- {}
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")
            emit Withdraw(id: token.id, from: self.owner?.address)
            return <-token
        }

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @LootOnChain.NFT
            let id: UInt64 = token.id
            let oldToken <- self.ownedNFTs[id] <- token
            emit Deposit(id: id, to: self.owner?.address)
            destroy oldToken
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        destroy() {
            destroy self.ownedNFTs
        }    
    
    }

    pub fun currentPrice() {

    }

    pub fun generateSVG(): String {
        let svg: String = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'>"
        svg.concat(self.part1)
        svg.concat(self.part2)
        svg.concat(self.part3)
        svg.concat("</svg>")
        return svg
    }

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    pub fun mintLoot(recipient: &{NonFungibleToken.CollectionPublic}) {

        let nftID = LootOnChain.totalSupply

        pre {
            // Make sure that the ID matches the current ID
            nftID == LootOnChain.totalSupply: "The given ID has already been minted."
            // Make sure that the ID is not greater than the max supply
            nftID < LootOnChain.maxSupply: "There are no LOOT left."
            // Make sure that the given vault has enough FLOW
            // vault.balance >= self.price: "The given FLOW vault doesn't have enough FLOW."
        }
        // https://github.com/onflow/flow-core-contracts/blob/master/transactions/flowToken/transfer_tokens.cdc


        

        if nftID < LootOnChain.maxSupply {

            // let recipients = getAccount(recipient)

            // let receiver = recipients.getCapability(LootOnChain.LootCollectionPublicPath)!
            //     .borrow<&{NonFungibleToken.CollectionPublic}>()
            //     ?? panic("Could not get receiver reference to the NFT Collection")

            // LootOnChain.idToAddress.append(recipient)
            recipient.deposit(token: <-create LootOnChain.NFT(initID: nftID))
            emit Minted(id: nftID)
            LootOnChain.totalSupply = nftID + (1 as UInt64)
        }
    }

    init(){

        self.LootCollectionStoragePath = /storage/LootCollection
        self.LootCollectionPublicPath = /public/LootCollection

        self.idToAddress = []

        self.maxSupply = 4444
        self.totalSupply = 0
        self.price = 50.0 // 20 FLOW per LOOT

        self.flowStorageFeePerHaiku = 0.00005 // Amount of FLOW to transfer

        self.part1 = "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>"
        self.part2 = "<rect width='100%' height='100%' fill='black' />"
        self.part3 = "<text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>EpicLordHamburger</text>"

        self.weapons = ["Warhammer","Quarterstaff","Maul","Mace","Club"]
        self.chestArmor = ["Divine Robe","Silk Robe","Linen Robe","Robe","Shirt"]
        self.headArmor = ["Ancient Helm","Ornate Helm","Great Helm","Full Helm","Helm"] 

        let collection <- create Collection()

        self.account.save(<-collection, to: self.LootCollectionStoragePath)

        // create a public capability for the collection
        self.account.link<&LootOnChain.Collection{NonFungibleToken.CollectionPublic, LootOnChain.LootOnChainPublicCollectiton}>(
            self.LootCollectionPublicPath,
            target: self.LootCollectionStoragePath
        )

        emit ContractInitialized()
    }

}