import "NeepNFT"
import "NonFungibleToken"

transaction(receiver: Address, name: String, image: String, description: String) {

    prepare(signer: AuthAccount) {
        let minter = signer.borrow<&NeepNFT.NFTMinter>(from: /storage/Minter) ?? panic("Could not get minter from the resource")

        let receiver = getAccount(receiver).getCapability(/public/Collection).borrow<&NeepNFT.Collection{NonFungibleToken.Receiver}>() ?? panic("Account does not have collection resource")

        receiver.deposit(token: <- minter.mintNFT(name: name, image: image, description: description))

    }

    execute {
        log("Minted NFT to user")
    }

}