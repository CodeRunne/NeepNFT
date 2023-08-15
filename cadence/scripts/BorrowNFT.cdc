import "NeepNFT"
import "NonFungibleToken"

pub fun main(address: Address, id: UInt64) {
    let collection = getAccount(address)
        .getCapability(/public/Collection).borrow<&NeepNFT.Collection{NeepNFT.NeepCollectionPublic, NonFungibleToken.CollectionPublic}>() 
        ?? panic("Could not get NFT collection resource for this account")

    let borrowedNFT = collection.borrowNeepNFT(id: id)
    log(borrowedNFT.name)
    log(borrowedNFT.image)
    log(borrowedNFT.description)
}