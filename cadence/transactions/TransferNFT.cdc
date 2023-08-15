import "NeepNFT"
import "NonFungibleToken"

transaction(receiver: Address, id: UInt64) {

    prepare(signer: AuthAccount) {
        let sender = signer.borrow<&NeepNFT.Collection{NonFungibleToken.Provider}>(from: /storage/Collection) ?? panic("Could not get collection for account")

        let receiver = getAccount(receiver).getCapability(/public/Collection).borrow<&NeepNFT.Collection{NonFungibleToken.Receiver}>() ?? panic("Account does not have collection resource")

        receiver.deposit(token: <- sender.withdraw(withdrawID: id))

    }

    execute {
        log("Transferred nft")
    }

}