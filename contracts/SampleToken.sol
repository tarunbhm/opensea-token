// SPDX-License-Identifier: MIT

pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import "./Strings.sol";


contract OwnableDelegateProxy { }

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract SampleToken is ERC721Token, Ownable {
    address proxyRegistryAddress;
    string baseURI;

    constructor (address _proxyRegistryAddress) ERC721Token("SampleToken", "ST") public {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function getTokenId(string memory lon, string memory lat) pure public returns (uint) {
        return uint(keccak256(abi.encodePacked(lon, ",", lat)));
    }

    function buyLand(string memory lon, string memory lat) public {
        uint _tokenId = getTokenId(lon, lat);
        // Check if token already sold
        require(!exists(_tokenId), "ERC721: Token already exists");
        _mint(msg.sender, _tokenId);
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        require(exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = tokenURIs[_tokenId];

        // Even if there is a base URI, it is only appended to non-empty token-specific URIs
        if (bytes(_tokenURI).length == 0) {
            return string(abi.encodePacked(baseURI, Strings.toString(_tokenId)));
        } else {
            // abi.encodePacked is being used to concatenate strings
            return string(abi.encodePacked(baseURI, _tokenURI));
        }
    }

    function setBaseURI(string _baseURI) external {
        baseURI = _baseURI;
    }

    /**
    * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
    */
    function isApprovedForAll(
        address owner,
        address operator
    )
        public
        view
        returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }
}