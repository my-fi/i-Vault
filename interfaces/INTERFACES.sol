//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "../utils/Context.sol";

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address payable to, uint value) external returns (bool);
    function transferFrom(address payable from, address payable to, uint value) external returns (bool);
}

interface IVAULT {
    event Transfer(address indexed from, address indexed to, uint value);

    function withdrawETH() external returns (bool);
    function withdrawToken(address token) external returns (bool);
    function split(uint liquidity) external view returns(uint,uint,uint);
    function transfer(address sender, uint256 eth, address payable receiver) external returns (bool success);
    function transferToken(address sender, uint256 amount, address payable receiver, address token) external returns (bool success);
}
