// SPDX-License-Identifier: None

pragma solidity ^0.8.13;

interface IERC721{
    function transferFrom(address _from, address _to, uint _nftId) external;
}

/* 

    Dutch Auction is concept where price decreases gradually as time passes, to a certain limit. This is auction for only 1 nft.
    We can use a factory/collection contract to deploy each auction, or just inhance it's functionality to support multiple nfts

    ****************  TESTING  ********************
    1. Deploy Nft.sol -> 2. Mint Nft  (i.e. _tokenId=999) -> 3. Deploy DuctionAuction.sol -> 
    4. Approve address of DuctchAction.sol by calling Nft.approve, and passing them address of dutchauction.sol and tokenId (999)
    5. Get the price of nft in auction -> 6. Send some wei/ethers to buy NFT
    7. Verify if buyer is same while calling Nft.ownerOf(999)


 */
contract DutchAuction{
    uint private constant DURATION = 7 days;
    IERC721 public immutable nft;

    uint public immutable nftId;

    address payable public immutable seller;

    uint public immutable startingPrice;

    uint public immutable startedAt;

    uint public immutable expiresAt;

    uint public immutable discountRate;

    constructor(uint _startingPrice, uint _discountRate, address _nftContract, uint _nftId){
        require(_startingPrice>=_discountRate*DURATION,"starting price < discount");

        seller=payable(msg.sender);

        startedAt = block.timestamp;

        expiresAt = startedAt + DURATION;

        startingPrice = _startingPrice;
        discountRate =  _discountRate;


        nft=IERC721(_nftContract);
        nftId=_nftId;
    }

    function getPrice() public view returns(uint){
        uint timeElapsed = block.timestamp - startedAt;
        uint discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }
    function buy() external payable{
        require(block.timestamp<expiresAt,"Auction expired");
        uint price = getPrice();
        require(msg.value>=price,"ETH<price");

        nft.transferFrom(seller,msg.sender, nftId);
        uint refund = msg.value - price;
        
        if(refund>0){
            payable(msg.sender).transfer(refund);
        }
        
        selfdestruct(seller); // Send ethers from contract to seller
    }
}