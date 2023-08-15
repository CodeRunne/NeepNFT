import "NeepNFT"
import "NonFungibleToken"

transaction {

    prepare(signer: AuthAccount) {
        if signer.borrow<&NeepNFT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic}>(from: /storage/Collection) == nil {
            signer.save(<- NeepNFT.createEmptyCollection(), to: /storage/Collection)

            signer.link<&NeepNFT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, NeepNFT.NeepCollectionPublic}>(/public/Collection, target: /storage/Collection)
        }
    }

    execute {
        log("Created an NFT collection")
    }

}