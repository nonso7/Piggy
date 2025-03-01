// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Piggybank} from "./Piggy.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract PiggybankFactory {
    event PiggybankDeployed(address indexed piggybankAddress, address indexed owner);
    event SavedSuccessfully(uint256 indexed _amount, address indexed token);
    event PiggybankClosed(address indexed contractAddress);
    
    struct Deposit {
        address piggybank;
        uint256 amount;
        uint256 startTime;
        address tokenAddress; 
        uint256 duration;  
    }

    address[] public usersPiggbank;
    Deposit[] trackDeposit;

    mapping(address => bool) public isDeployed;
    mapping(address => Deposit[]) public saverHistory;
    mapping(address => string) public userPurpose;
    mapping(address => bool) public isAllowedToken;
    mapping(address => bool) public isWithdrawn;
    address[] public allowedTokens;

    constructor(address[] memory _allowedTokens) {
        require(_allowedTokens.length == 3, "Must provide exactly 3 tokens");
        allowedTokens = _allowedTokens;
        for (uint256 i = 0; i < _allowedTokens.length; i++) {
            isAllowedToken[_allowedTokens[i]] = true;
        }
    }

    //this will deploy a new piggybank contract at the precomputed address
    function deployPiggybank(
    uint256 salt,
    uint256 _startTime,
    uint256 _duration,
    address[] memory _allowedTokens
) external returns (address) {
    Piggybank piggybank = new Piggybank{
        salt: bytes32(salt)
    }(_startTime, _duration,  _allowedTokens);

    isDeployed[address(piggybank)] = true;
    usersPiggbank.push(address(piggybank));    

    emit PiggybankDeployed(address(piggybank), msg.sender);
    return address(piggybank);
}



function DepositDetails(address _Eachsaver, address _piggyBank, uint256 _amount, uint256 _startTime, address _tokenAddress, string memory _purpose, uint256 _duration) external {
    require(isAllowedToken[_tokenAddress], "Token not allowed");
    require(isDeployed[address(_piggyBank)], "Invalid deployed Address");
    require(_amount > 0, "Amount must be greater than zero");

    bool txn = IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
    require(txn, "txn failed");
    saverHistory[_Eachsaver].push(Deposit(_piggyBank, _amount, _startTime, _tokenAddress, _duration));
    userPurpose[_Eachsaver] = _purpose;

    emit SavedSuccessfully(_amount, _tokenAddress);
}

    function markAsWithdrawn(address piggybank) external {
        require(isDeployed[piggybank], "Invalid Piggybank contract");
        require(!isWithdrawn[piggybank], "Piggybank already closed");

        bool hasFunds = false;
        // Ensure the piggybank has no funds left
        for (uint256 i = 0; i < allowedTokens.length; i++) {
            if (IERC20(allowedTokens[i]).balanceOf(piggybank) > 0) {
                hasFunds = true;
                break;
            }
        }
        require(!hasFunds, "Piggybank still has funds");

        isWithdrawn[piggybank] = true;
        isDeployed[piggybank] = false;

        emit PiggybankClosed(piggybank);
    }

function getDepositHistory(address saver) external view returns(Deposit[] memory){
     return saverHistory[saver];
}
   



    //this returns the future contract address before it is been deployed
    //this lets external contracts or users know where the contract will be deployed
    function computePiggybankAddress(
        bytes32 salt,
        uint256 _startTime,
        uint256 _duration,
        string memory _purpose,
        address[] memory _allowedTokens
    ) public view returns (address) {
        bytes memory bytecode = type(Piggybank).creationCode;
        bytes memory payload = abi.encode(_startTime, _duration, _purpose, _allowedTokens);

        return address(uint160(uint(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            salt,
            keccak256(abi.encodePacked(bytecode, payload))
        )))));
    }
}