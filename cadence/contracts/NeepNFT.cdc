import "NonFungibleToken"

pub contract NeepNFT: NonFungibleToken {

    // NFT totalsupply
    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    /// Storage and Public Paths
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    pub resource interface NeepCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowNeepNFT(id: UInt64): &NFT
    }

    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, NeepCollectionPublic {

        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @NeepNFT.NFT
            emit Deposit(id: token.id, to: self.owner?.address)
            self.ownedNFTs[token.id] <-! token
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let nft <- self.ownedNFTs.remove(key: withdrawID) ?? panic("Nft not found in collection")

            emit Withdraw(id: withdrawID, from: self.owner?.address)

            return <- nft
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        pub fun borrowNeepNFT(id: UInt64): &NFT {
            let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            return nft as! &NFT 
        }

        init() {
            self.ownedNFTs <- {}
        }

        destroy() {
            destroy self.ownedNFTs
        }

    }

    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64

        pub let name: String
        pub let image: String
        pub let description: String

        init(name: String, image: String, description: String) {
            self.id = NeepNFT.totalSupply
            self.name = name
            self.image = image
            self.description = description
        }
    }

    pub resource NFTMinter {

        pub fun mintNFT(name: String, image: String, description: String): @NFT {
            NeepNFT.totalSupply = NeepNFT.totalSupply + UInt64(1)
            return <- create NFT(name: name, image: image, description: description)
        }

    }

    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }    

    init() {
        self.totalSupply = 0

        self.CollectionStoragePath = /storage/Collection
        self.CollectionPublicPath = /public/Collection
        self.MinterStoragePath = /storage/Minter

        // Create a Collection resource and save it to storage
        let collection <- create Collection()
        self.account.save(<-collection, to: self.CollectionStoragePath)

        // create a public capability for the collection
        self.account.link<&NeepNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, NonFungibleToken.Provider}>(
            self.CollectionPublicPath,
            target: self.CollectionStoragePath
        )

        let minter <- create NFTMinter()
        self.account.save(<- minter, to: /storage/Minter)

        emit ContractInitialized()
    }

}