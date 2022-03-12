// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract CoinFlip {
    struct User {
        address payable addr;
        uint balance;
        bool inGame;
        bool inBet;
        uint betAmount;
        uint flipVal;
    }

    User[] users;

    function userIndex(address _addr) public view returns (uint) {
        for(uint i=0; i<users.length; i++){
            if(users[i].addr == _addr) return i;
        }
        return users.length;
    }

    function enterGame() public {
        address payable _addr = payable(msg.sender);
        uint idx = userIndex(_addr);
        if(idx == users.length){
            users.push(User(_addr,100,true,false,0,0));
        }
        else {
            require(users[idx].inGame == false, "You are already in the game.");
            users[idx].balance = 100;
            users[idx].inGame = true;
            users[idx].inBet = false;
            users[idx].betAmount = 0;
            users[idx].flipVal = 0;
        }
    }

    function exitGame() public {
        uint idx = userIndex(msg.sender);
        require(idx < users.length, "You never entered in this Game.");
        require(users[idx].inGame == true, "You have already exited.");
        users[idx].balance = 0;
        users[idx].inGame = false;
        users[idx].inBet = false;
        users[idx].betAmount = 0;
        users[idx].flipVal = 0;
    }

    function viewBalance() public view returns (uint) {
        uint idx = userIndex(msg.sender);
        if(idx == users.length) return 0;
        return users[idx].balance;
    }

    function bet(uint _betAmount, uint _flipVal) public {
        uint idx = userIndex(msg.sender);
        require(idx < users.length && users[idx].inGame == true, "You have not entered the Game.");
        require(_flipVal < 2, "Please enter 0/1 in _flipVal.");
        require(_betAmount <= users[idx].balance, "You have exceeded your balance.");
        require(users[idx].inBet == false, "You are already in this bet.");
        users[idx].inBet = true;
        users[idx].balance -= _betAmount;
        users[idx].betAmount = _betAmount;
        users[idx].flipVal = _flipVal;
    }

    function rewardBets() internal {
        uint _flipVal = 0;
        for(uint i=0; i<users.length; i++){
            if(users[i].inGame && users[i].inBet){
                if(users[i].flipVal == _flipVal)users[i].balance += 2*users[i].betAmount;
                users[i].inBet = false;
                users[i].betAmount = 0;
                users[i].flipVal = 0;
            }
        }
    }
    
    function vrf() public view returns (bytes32 result) {
        uint[1] memory bn;
        bn[0] = block.number;
        assembly {
        let memPtr := mload(0x40)
        if iszero(staticcall(not(0), 0xff, bn, 0x20, memPtr, 0x20)) {
            invalid()
        }
        result := mload(memPtr)
        }
    }
}