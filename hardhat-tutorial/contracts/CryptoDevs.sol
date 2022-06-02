//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";


contract CryptoDevs is ERC721Enumerable, Ownable{
    string _baseTokenURI;
    IWhitelist whitelist; 
    bool public presaleStarted;
    uint256 public preSaleEnded;
    uint public maxTokenIds = 20;
    uint public tokenIds;
    uint public _price = 0.01 ether;
    bool public _paused;

    modifier onlyWhenNotPaused{
        require(!_paused, "Contract Currently Paused");
        _;
    }


    constructor(string memory baseURI, address whitelistContract) ERC721("CryptoDevs","CD"){
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    function startPresale() public onlyOwner{
        presaleStarted = true;
        preSaleEnded = block.timestamp + 5 minutes;

    }
    function persaleMint() public payable onlyWhenNotPaused{
        require(presaleStarted && block.timestamp < preSaleEnded, "Presale Ended");
        require(whitelist.whitelistedAddresses(msg.sender),"You are not Authorised");
        require(tokenIds < maxTokenIds, "Exceeded the Limit");
        require(msg.value >= _price, "Ether sent is not correct");

        tokenIds +=1;

        _safeMint(msg.sender, tokenIds);

    }
    function mint() public payable onlyWhenNotPaused{

        require(presaleStarted && block.timestamp > preSaleEnded, "Presale Not ended yet");
        require(tokenIds < maxTokenIds, "Exceeded the Limit");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds+=1;

        _safeMint(msg.sender, tokenIds);
    }

    function _baseURI() internal view override returns (string memory){
        return _baseTokenURI;
    }
    function withdraw() public onlyOwner{
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent,) = _owner.call{value:amount}("");
        require(sent, "Failed to send ether");
    }

    function setPaused(bool val) public onlyOwner{

    }
    receive() external payable{
    }

    fallback() external payable {

    }
} 
