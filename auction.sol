pragma solidity >=0.7.0 <0.9.0;

contract simoleAuction{
    //variable
    uint public auctionEndTime;
    uint public highestBid;

    bool ended = false;

    address highestBidder;
    address payable public beneficiary;

    mapping(address => uint) public pendingReturns;
    event highestBitIncrease(address bidder, uint amount);
    event auctionEnded(address winner, uint amount);

    constructor (uint _biddingTime, address payable _beneficiary){
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }
    //Function
    function bid() public payable{ //payable: la 1 lop bao mat
        if(block.timestamp > auctionEndTime){ // thoi gian ko duoc lon hon phien dau gia
            revert('Phien dau gia da ket thuc');
        }

        if(msg.value <= highestBid){ //chi duoc tra gia cao hon
            revert("Gia cua ban dang thap hon gia cao nhat");
        }

        if(highestBid != 0){ // So tien > 0
            pendingReturns[highestBidder] += highestBid; //nguoi dat gia cao nhat va gia cao nhat
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit highestBitIncrease(msg.sender, msg.value);
    }

    function withdraw() public returns(bool){ //true thi dc rut false thi ko duoc rut
        uint amount = pendingReturns[msg.sender];
        if (amount > 0){
            pendingReturns[msg.sender] = 0; // sau khi rut xong thi moi thu se tro ve 0
            if(payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount; // rut ko dc thi tro lai ban dau
                return false;
            }
        }
        return true; // true thi dc rut tien
    }

    function auctionEnd() public{
        if(ended == false){
            revert('Thoi gian dau gia chua ket thuc');
        }

        if(block.timestamp < auctionEndTime){
            revert('Thoi gian chua ket thuc');
        }

        ended = true;
        emit auctionEnded(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }
}