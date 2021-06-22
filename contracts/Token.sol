// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {
    
    using SafeMath for uint256;

    string public tokenName;
    string public tokenSymbol;
    uint8 public tokenDecimals;
    uint256 public initalSupply;

    
   
    struct tokenStruct {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }
    mapping(address => uint256) public balance;
    mapping(address => tokenStruct) public locked;


    constructor(string memory _name, string memory _symbol, uint256 _totalSupply, uint8 _decimals) ERC20(_name, _symbol) {
        tokenName = _name;
        tokenSymbol = _symbol;
        tokenDecimals = _decimals;
        initalSupply = _totalSupply;
    }

    function mint(address _owner, uint256 _amount) public onlyOwner {
        require(_owner!=address(0),"Address cannot be zero");
        require(_amount <= initalSupply,"Token supply not exist");
        initalSupply=initalSupply.sub(_amount);
        balance[_owner]=balance[_owner].add(_amount);
        _mint(_owner, _amount);

        
    }

    function burn(address _owner, uint256 _amount) public onlyOwner {
         require(_owner != address(0),"Address cannot be zero");
         require(_amount <= balance[_owner],"amount not exist");
        _burn(_owner, _amount);
        initalSupply=initalSupply.add(_amount);
    }

    function lock(address _owner, uint256 _amount, uint256 _time) public returns (bool){

        require(_amount != 0,"Amount cannot be zero");
        require(_owner!=address(0),"Address cannot be zero");

        require(checktokensLocked(_owner) == 0,"Already Locked");

        uint256 validtime = block.timestamp.add(_time);
        transfer(address(this), _amount);
        locked[msg.sender] = tokenStruct(_amount, validtime, false);

        return true;

    }

    function unlock(address _owner) public returns(uint256) {

        uint256 tokenLock =  checktokensLocked(_owner);
        transfer(_owner, tokenLock);
        locked[_owner].claimed = true;
        return tokenLock;
    }


    function checktokensLocked(address _owner)public view returns (uint256 amount)
    {
        if (!locked[_owner].claimed)
        amount = locked[_owner].amount;
            
    }
    
   

    
    
}