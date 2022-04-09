// SPDX-License-Identifier: None

pragma solidity ^0.8.9;

interface IERC721{
    function transferFrom(
        address from,
        address to,
        uint nftId
    ) external;
}

contract EnglishAuction {
    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address highestBidder, uint amount);


    IERC721 public immutable nft;
    uint public immutable nftId; 

    address payable public immutable seller;
    uint32  public endAt; // uint32 can store upto 100 years from now
    bool public started;
    bool public ended;

    address public highestBidder;
    uint public highestBid;

    mapping(address=>uint) public bids;

    constructor(address _nft, uint _nftId, uint _startingBid){
        nft=IERC721(_nft);
        nftId=_nftId;
        seller = payable(msg.sender);
        highestBid = _startingBid;
    }   
    function start() external{
        require(msg.sender==seller, "not seller");
        require(!started,"Auction already started");
        
        started=true;
        endAt = uint32(block.timestamp + 60 );

        nft.transferFrom(seller,address(this), nftId);
        emit Start();
    }  

    function bid() external payable{
        require(started,"not started");
        require(block.timestamp< endAt,"Auction ended");
        require(msg.value>highestBid,"You must bid more than previous bidder");
        if(highestBidder!=address(0)){
            bids[highestBidder]+=highestBid;
        }

        highestBid=msg.value;
        highestBidder = msg.sender; 

        emit Bid(msg.sender, msg.value);
    }

    function withdraw() external{
        uint bal = bids[msg.sender];
        bids[msg.sender]=0;

        payable(msg.sender).transfer(bal);

        emit Withdraw(msg.sender, bal);

    }

    function end() external{
        require(started,"not started");
        require(!ended, "ended");
        require(block.timestamp>=endAt,"not ended");

        ended= true;

        if(highestBidder!=address(0)){
            nft.transferFrom(address(this), highestBidder, nftId);
        }else{
            nft.transferFrom(address(this), seller, nftId);
        }

        seller.transfer(highestBid);

        emit End(highestBidder, highestBid);
    }

}