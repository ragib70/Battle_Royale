// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract GunItems is ERC1155{
    
    mapping (string => uint256) public index;
    
    constructor() ERC1155("https://gateway.pinata.cloud/ipfs/QmdkJBp4hyyHzFSSrY7YL72ok2s1jdXGnVUxL5qXhKZs29/{id}.json"){
        index["Kalashnikov"] = 1;
        index["Uzi"] = 2;
    }
    
    function mint(address sendTo_, string memory tokenName) external{
        require(index[tokenName] > 0, "The Gun is not present");
        _mint(sendTo_, index[tokenName], 1, "");
    }
    
    function uri(uint256 _tokenID) override public view returns (string memory){
        return string(
            abi.encodePacked(
                "https://gateway.pinata.cloud/ipfs/QmdkJBp4hyyHzFSSrY7YL72ok2s1jdXGnVUxL5qXhKZs29/",
                Strings.toString(_tokenID),
                ".json"
            )
        );
    }
}
