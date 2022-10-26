//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IVAULT {
    event Transfer(address indexed from, address indexed to, uint value);

    function withdrawETH() external returns (bool);
    function withdrawToken(address token) external returns (bool);
    function split(uint liquidity) external view returns(uint,uint,uint);
    function transfer(address sender, uint256 eth, address payable receiver) external returns (bool success);
    function transferToken(address sender, uint256 amount, address payable receiver, address token) external returns (bool success);
}
