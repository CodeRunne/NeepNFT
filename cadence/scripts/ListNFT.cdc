import "NeepNFT"
import "NonFungibleToken"

pub fun main(address: Address): [UInt64] {
    let collection = getAccount(address).getCapability(/public/Collection).borrow<&NeepNFT.Collection{NonFungibleToken.CollectionPublic}>() 
        ?? panic("Could not get collection resource for this account")
    
    return collection.getIDs()
}