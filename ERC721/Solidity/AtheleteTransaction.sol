pragma solidity ^0.4.23;
import "./Club.sol";
import "./Agency.sol";
import "./modifiedERC721.sol";
import "./SafeMath.sol";

contract AthleteTransaction is modifiedERC721,Agency,Club{
    using SafeMath for uint256;
    mapping (string => address) internal tokenOwner;
    mapping (string => address) tokenApprovals;
    
    modifier legitCaller(string _tokenId){
        require((msg.sender == clubLookup[_tokenId]) || (msg.sender == agencyLookup[_tokenId]));
        _;
    }
    
    function ownerOf(string _tokenId) public view returns (address _owner) {
        if (clubLookup[_tokenId] == 0){
            if (agencyLookup[_tokenId] != 0){
                return agencyLookup[_tokenId];
            }
            else{
                revert();
            }
        }
        return clubLookup[_tokenId];
    }
    
    function _transfer(address _from, address _to, string _tokenId) private {
        if (clubLookup[_tokenId] == 0){
            if (agencyLookup[_tokenId] != 0){
                agencyLookup[_tokenId] = _to;
                emit Transfer(_from, _to, _tokenId);
            }
        }
        else{
            clubLookup[_tokenId] = _to;
            emit Transfer(_from, _to, _tokenId);
        }
    }
    
    function transfer(address _to, string _tokenId) public legitCaller(_tokenId){
        _transfer(msg.sender, _to, _tokenId);
    }
    
    function approve(address _to, string _tokenId) public legitCaller(_tokenId){
        tokenApprovals[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }
    
    function takeOwnership(string _tokenId) public legitCaller(_tokenId){
        address owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }
    
    function exists(string _tokenId) public view returns (bool) {
        address owner = ownerOf(_tokenId);
        return owner != address(0);
    }
    
    function _mint(address _to, string _tokenId) internal {
        require(_to != address(0));
        addTokenTo(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }

    function _burn(address _owner, string _tokenId) internal {
        clearApproval(_owner, _tokenId);
        removeTokenFrom(_owner, _tokenId);
        emit Transfer(_owner, address(0), _tokenId);
    }
    
    function clearApproval(address _owner, string _tokenId) internal {
        require(ownerOf(_tokenId) == _owner);
        if (tokenApprovals[_tokenId] != address(0)) {
            tokenApprovals[_tokenId] = address(0);
            emit Approval(_owner, address(0), _tokenId);
        }
    }
    
    function addTokenTo(address _to, string _tokenId) internal {
        require(tokenOwner[_tokenId] == address(0));
        tokenOwner[_tokenId] = _to;
    }
    
    function removeTokenFrom(address _from, string _tokenId) internal {
        require(ownerOf(_tokenId) == _from);
        tokenOwner[_tokenId] = address(0);
    }

}