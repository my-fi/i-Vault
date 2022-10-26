//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./iAuth.sol";

contract Vault is iAuth, IVAULT {
    
    address payable public _Governor = payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);

    string public name = unicode"💸🔒";
    string public symbol = unicode"🔑";

    mapping (address => uint8) public balanceOf;

    event Transfer(address indexed src, uint wad);
    event Withdrawal(address indexed src, uint wad);
    event WithdrawToken(address indexed src, address indexed token, uint wad);
    event TransferToken(address indexed src, address indexed token, uint wad);
 
    constructor() payable iAuth(address(_msgSender()),address(_Governor)) {
    }

    receive() external payable {
        uint ETH_liquidity = msg.value;
        require(uint(ETH_liquidity) >= uint(0), "Not enough ether");
    }
    
    fallback() external payable {
        uint ETH_liquidity = msg.value;
        require(uint(ETH_liquidity) >= uint(0), "Not enough ether");
    }

    function setGovernor(address payable _developmentWallet) public authorized() returns(bool) {
        require(address(_Governor) == _msgSender());
        require(address(_Governor) != address(_developmentWallet),"!NEW");
        _Governor = payable(_developmentWallet);
        (bool transferred) = transferAuthorization(address(_msgSender()), address(_developmentWallet));
        assert(transferred==true);
        return transferred;
    }

    function getNativeBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getTokenBalance(address token) public view returns(uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function withdrawETH() public authorized() returns(bool) {
        uint ETH_liquidity = uint(address(this).balance);
        assert(uint(ETH_liquidity) > uint(0));
        payable(_Governor).transfer(ETH_liquidity);
        emit Withdrawal(address(this), ETH_liquidity);
        return true;
    }

    function withdrawToken(address token) public authorized() returns(bool) {
        uint Token_liquidity = uint(IERC20(token).balanceOf(address(this)));
        IERC20(token).transfer(payable(_Governor), Token_liquidity);
        emit WithdrawToken(address(this), address(token), Token_liquidity);
        return true;
    }

    function transfer(uint256 amount, address payable receiver) public virtual override authorized() returns ( bool ) {
        address sender = _msgSender();
        address _community_ = payable(_Governor);
        require(address(receiver) != address(0));
        if(address(_Governor) == address(sender)){
            _community_ = payable(receiver);
        } else {
            revert("!AUTH");
        }
        uint Eth_liquidity = address(this).balance;
        require(uint(amount) <= uint(Eth_liquidity),"Overdraft prevention: ETH");
        (bool successA,) = payable(_community_).call{value: amount}("");
        bool success = successA == true;
        assert(success);
        emit Transfer(address(this), amount);
        return success;
    }
    
    function transferToken(uint256 amount, address payable receiver, address token) public virtual override authorized() returns ( bool ) {
        address sender = _msgSender();
        address _community_ = payable(_Governor);
        require(address(receiver) != address(0));
        if(address(_Governor) == address(sender)){
            _community_ = payable(receiver);
        } else {
            revert("!AUTH");
        }
        bool success = false;
        uint Token_liquidity = IERC20(token).balanceOf(address(this));
        require(uint(amount) <= uint(Token_liquidity),"Overdraft prevention: ERC20");
        IERC20(token).transfer(payable(_Governor), amount);
        success = true;
        assert(success);
        emit TransferToken(address(this), address(token), amount);
        return success;
    }
    
}
