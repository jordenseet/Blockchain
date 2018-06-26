pragma solidity ^0.4.23;
/*@dev removed balanceOf function since the number of Athletes or Agents in their Club or Agency respectively is redundant for this scenario
  @dev also changed the _tokenId type from uint to string to fit scenario
*/
contract modifiedERC721 {
    event Transfer(address indexed _from, address indexed _to, string _tokenId);
    event Approval(address indexed _owner, address indexed _approved, string _tokenId);

    function ownerOf(string _tokenId) public view returns (address _owner);
    function transfer(address _to, string  _tokenId) public;
    function approve(address _to, string _tokenId) public;
    function takeOwnership(string _tokenId) public;
    function exists(string _tokenId) public view returns (bool _exists);
}
