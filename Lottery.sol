// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Lottery {

    uint256 totalNumberOfParticipants=2;
    uint256 randomNumber = 4;
    uint256 winnerIndex;
    address  winner;
    address[] participants;


    function bet() external payable returns(bool status){
        //20000000 gwei
        require((participants.length<=totalNumberOfParticipants) && (msg.value == .02 ether));
            participants.push(msg.sender);
            return true;
        } 



    function pickWinner()  external  returns(address){
        require(participants.length == totalNumberOfParticipants);
        winnerIndex = randomNumber%2;
        winner = participants[winnerIndex];
        payable(winner).transfer(address(this).balance);
        reset();
        return winner;

    }


    function reset() internal {
        delete participants;
    }

} 
