//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./iAuth.sol";

contract Vault is iAuth, IVAULT {
    
    address payable public _Governor = payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD);

    string public name = unicode"💸🔒";
    string public symbol = unicode"🔑";

    mapping (address => uint8) public balanceOf;
    mapping (address => uint) public coinAmountOwed;
    mapping (address => uint) public coinAmountDrawn;
    mapping (address => uint) public tokenAmountOwed;
    mapping (address => uint) public tokenAmountDrawn;

    event Transfer(address indexed src, uint wad);
    event Withdrawal(address indexed src, uint wad);
    event WithdrawToken(address indexed src, address indexed token, uint wad);
    event TransferToken(address indexed src, address indexed token, uint wad);
 
    constructor() payable iAuth(address(_msgSender()),address(_Governor)) {
        if(uint256(msg.value) > uint256(0)){
            coinDeposit(uint256(msg.value));
        }
    }

    receive() external payable {
        uint ETH_liquidity = msg.value;
        require(uint(ETH_liquidity) >= uint(0), "Not enough ether");
        coinDeposit(uint256(ETH_liquidity));
    }
    
    fallback() external payable {
        uint ETH_liquidity = msg.value;
        require(uint(ETH_liquidity) >= uint(0), "Not enough ether");
        coinDeposit(uint256(ETH_liquidity));
    }

    function setGovernor(address payable _developmentWallet) public authorized() returns(bool) {
        require(address(_Governor) == _msgSender());
        require(address(_Governor) != address(_developmentWallet),"!NEW");
        coinAmountOwed[address(_developmentWallet)] += coinAmountOwed[address(_Governor)];
        coinAmountOwed[address(_Governor)] = 0;
        _Governor = payable(_developmentWallet);
        (bool transferred) = transferAuthorization(address(_msgSender()), address(_developmentWallet));
        assert(transferred==true);
        return transferred;
    }

    function getNativeBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function coinDeposit(uint256 amountETH) internal returns(bool) {
        uint ETH_liquidity = amountETH;
        return store(_msgSender(),uint(ETH_liquidity));
    }

    function store(address _depositor, uint eth_liquidity) internal returns(bool) {
        coinAmountOwed[address(_depositor)] += uint(eth_liquidity);
        return true;
    }

    function withdrawETH() public authorized() returns(bool) {
        uint ETH_liquidity = uint(address(this).balance);
        assert(uint(ETH_liquidity) > uint(0));
        coinAmountDrawn[address(_Governor)] += coinAmountOwed[address(_Governor)];
        coinAmountOwed[address(_Governor)] = 0;
        payable(_Governor).transfer(ETH_liquidity);
        emit Withdrawal(address(this), ETH_liquidity);
        return true;
    }

    function withdrawToken(address token) public authorized() returns(bool) {
        uint Token_liquidity = uint(IERC20(token).balanceOf(address(this)));
        tokenAmountDrawn[address(_Governor)] += Token_liquidity;
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
        coinAmountOwed[address(_Governor)] += uint(Eth_liquidity);
        coinAmountDrawn[address(_Governor)] += uint(amount);
        coinAmountOwed[address(_Governor)] -= uint(amount);
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
        tokenAmountOwed[address(_Governor)] -= uint(Token_liquidity);
        tokenAmountDrawn[address(_Governor)] += uint(amount);
        tokenAmountOwed[address(_Governor)] -= uint(amount);
        IERC20(token).transfer(payable(_Governor), amount);
        success = true;
        assert(success);
        emit TransferToken(address(this), address(token), amount);
        return success;
    }
    
}
