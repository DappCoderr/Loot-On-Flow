import NonFungibleToken from "./NonFungibleToken.cdc"
import FungibleToken from "./FungibleToken.cdc"
import FlowToken from "./FlowToken.cdc"
// import FUSD from "./FUSD.cdc"

pub contract LootOnChain: NonFungibleToken {

    pub let LootCollectionStoragePath: StoragePath
    pub let LootCollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    access(self) let idToAddress: [Address]

    pub let weapons: [String] 
    pub let chestArmor: [String] 
    pub let headArmor: [String] 
    // pub let necklaces: [String]
    // pub let rings: [String]
    // pub let waistArmor: [String]

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

    pub struct Metadata { 
        pub let svg: String
        init(svg: String){
            self.svg = svg
        }
    }

    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64
        pub let svg: String
        init(id:UInt64, svg:String){
            self.id = id;
            self.svg = svg
        }

        // pub fun getSVG(): String {}
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
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("Missing NFT")
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

    pub fun getMintPrice(): UFix64 {
        return self.price
    }

   pub fun getRandomWeapon() {}
   pub fun getRandomChestArmor() {}
   pub fun getRandomHeadArmor() {}
   pub fun getRandomNecklaces() {}
   pub fun getRamdomRings() {}
   pub fun getRandomWaistArmor() {}


    pub fun generateSVG(): String {

        var svg : String  = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'>"
        svg = svg.concat("<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>")
        svg = svg.concat("<rect width='100%' height='100%' fill='black' />")
        svg = svg.concat("<text x='50%' y='10%' class='base' dominant-baseline='middle' text-anchor='middle'>")
        svg = svg.concat("Epic")
        svg = svg.concat("</text>")
        svg = svg.concat("<text x='50%' y='20%' class='base' dominant-baseline='middle' text-anchor='middle'>")
        svg = svg.concat("Lord")
        svg = svg.concat("</text>")
        svg = svg.concat("<text x='50%' y='30%' class='base' dominant-baseline='middle' text-anchor='middle'>")
        svg = svg.concat("Hamburger")
        svg = svg.concat("</text>")
        svg = svg.concat("<text x='50%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle'>")
        svg = svg.concat("Knife")
        svg = svg.concat("</text>")
        svg = svg.concat("<text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>")
        svg = svg.concat("Gorza")
        svg = svg.concat("</text>")
        svg = svg.concat("</svg>")
        return svg

        // pub let parts: [String]
        // parts[0] = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'>"
        // parts[1] = "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>"
        // parts[2] = "<rect width='100%' height='100%' fill='black' />"
        // parts[3] = "<text x='50%' y='10%' class='base' dominant-baseline='middle' text-anchor='middle'>"
        // parts[4] = self.getRandomWeapon()
        // parts[5[ = "</text>"
        // parts[3] = "<text x='50%' y='10%' class='base' dominant-baseline='middle' text-anchor='middle'>"
        // parts[4] = self.getRandomChestArmor()
        // parts[5[ = "</text>"
        // parts[3] = "<text x='50%' y='20%' class='base' dominant-baseline='middle' text-anchor='middle'>"
        // parts[4] = self.getRandomHeadArmor()
        // parts[5[ = "</text>"
        // parts[3] = "<text x='50%' y='30%' class='base' dominant-baseline='middle' text-anchor='middle'>"
        // parts[4] = self.getRandomNecklaces()
        // parts[5[ = "</text>"
        // parts[3] = "<text x='50%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle'>"
        // parts[4] = self.getRamdomRings()
        // parts[5[ = "</text>"
        // parts[3] = "<text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>"
        // parts[4] = self.getRandomWaistArmor()
        // parts[5[ = "</text>"
        // parts[8] = ("</svg>")
        // return svg
    }

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // pub fun mintLoot(recipient: &{NonFungibleToken.CollectionPublic}) {

    //     let nftID = LootOnChain.totalSupply

    //     // pre {
    //     //     // Make sure that the ID matches the current ID
    //     //     nftID == LootOnChain.totalSupply: "The given ID has already been minted."
    //     //     // Make sure that the ID is not greater than the max supply
    //     //     nftID < LootOnChain.maxSupply: "There are no LOOT left."
    //     //     // Make sure that the given vault has enough FLOW
    //     //     // vault.balance >= self.price: "The given FLOW vault doesn't have enough FLOW."
    //     // }
    //     // https://github.com/onflow/flow-core-contracts/blob/master/transactions/flowToken/transfer_tokens.cdc


        

    //     if nftID < LootOnChain.maxSupply {

    //         // let recipients = getAccount(recipient)

    //         // let receiver = recipients.getCapability(LootOnChain.LootCollectionPublicPath)!
    //         //     .borrow<&{NonFungibleToken.CollectionPublic}>()
    //         //     ?? panic("Could not get receiver reference to the NFT Collection")

    //         // LootOnChain.idToAddress.append(recipient)
    //         recipient.deposit(token: <-create LootOnChain.NFT(initID: nftID))
    //         emit Minted(id: nftID)
    //         LootOnChain.totalSupply = nftID + (1 as UInt64)
    //     }
    // }

    pub resource NFTMinter {

        pub fun mintNFT( recipient: &{NonFungibleToken.CollectionPublic}) {
            recipient.deposit(token: <-create LootOnChain.NFT(id: LootOnChain.totalSupply, svg : LootOnChain.generateSVG()))
            emit Minted(id: LootOnChain.totalSupply)
            LootOnChain.totalSupply = LootOnChain.totalSupply + (1 as UInt64)
        }
    }

    init(){

        self.LootCollectionStoragePath = /storage/LootCollection
        self.LootCollectionPublicPath = /public/LootCollection
        self.MinterStoragePath = /storage/LootNFTMinter

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
        // self.necklaces = ["Necklace","Amulet","Pendant"];
        // self.rings = ["Gold Ring","Silver Ring","Bronze Ring","Platinum Ring","Titanium Ring"];
        // self.waistArmor = ["Ornate Belt","War Belt","Plated Belt","Mesh Belt","Heavy Belt"]


        // let collection <- create Collection()

        // self.account.save(<-collection, to: self.LootCollectionStoragePath)

        // create a public capability for the collection
        // self.account.link<&LootOnChain.Collection{NonFungibleToken.CollectionPublic, LootOnChain.LootOnChainPublicCollectiton}>(
        //     self.LootCollectionPublicPath,
        //     target: self.LootCollectionStoragePath
        // )

        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
    }

}