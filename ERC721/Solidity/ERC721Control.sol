pragma solidity ^0.4.23;

import "./modifiedERC721.sol";


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is modifiedERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (string _tokenId);
    function tokenByIndex(uint256 _index) public view returns (string);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is modifiedERC721 {
    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    function tokenURI(string _tokenId) public view returns (string);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Control is modifiedERC721, ERC721Enumerable, ERC721Metadata {
}