// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Piggybank {

    event SavedSuccessfully(uint256 indexed _amount, address indexed token);
    event WithdrawalSuccessful(uint256 indexed _amount, address indexed token);
    event EmergencyWithdraw(uint256 indexed finalAmount, uint256 indexed penalty, address indexed token);

    uint256 public constant PERCENTAGE_BASE = 10000; // 100% = 10,000 (bps)
    uint256 public constant FIFTEEN_PERCENT = 1500;

    address[] public allowedTokens;
    uint256 public startTime;
    uint256 public duration;
    //string public purpose;
    address public owner;
    mapping(address => uint256) public balance;
    mapping(address => bool) public hasSaved;

    constructor(uint256 _startTime, uint256 _duration,  address[] memory _allowedTokens) {
        startTime = _startTime;
        duration = _duration;
        allowedTokens = _allowedTokens;
        owner = msg.sender;
    }


    function AllowedTokens(address _token) public view returns(bool) {
        for(uint256 i = 0; i < allowedTokens.length; i++) {
            if(allowedTokens[i] == _token) {
                return true;
            }
        }
        return false;
    }

    function withdraw(uint256 amount, address _tokenAddress) external {
        AllowedTokens(_tokenAddress);
        require(block.timestamp >= startTime + duration, "Cannot withdraw before duration");
        require(IERC20(_tokenAddress).balanceOf(address(this)) >= amount, "Insufficeint contract balance");
        require(hasSaved[msg.sender] != false, "hasnt saved before");
        
        balance[msg.sender] += amount;
        bool txn = IERC20(_tokenAddress).transfer(msg.sender, amount);
        require(txn, "Failed txn");

        emit WithdrawalSuccessful(amount, _tokenAddress);
  
    }

    function emergencyWithdraw(uint256 amount, address _tokenAddress) external {
        AllowedTokens(_tokenAddress);
        require(block.timestamp < startTime + duration, "Use the withdrse");
        require(IERC20(_tokenAddress).balanceOf(address(this)) >= amount, "Insufficeint contract balance");
        require(hasSaved[msg.sender] != false, "hasnt saved before");

        uint256 penaltyFee = (amount * FIFTEEN_PERCENT) / PERCENTAGE_BASE;
        uint256 finalPayOut = amount - penaltyFee;

        balance[msg.sender] -= amount;
        require(IERC20(_tokenAddress).transfer(msg.sender, finalPayOut));
        require(IERC20(_tokenAddress).transfer(address(this), penaltyFee));

        emit EmergencyWithdraw(finalPayOut, penaltyFee, _tokenAddress);

    }

}