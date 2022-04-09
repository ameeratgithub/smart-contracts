//   SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function allowance(address _from, address _spender)
        external
        view
        returns (uint256);

    function approve(address _spender, uint256 _amount) external returns (bool);

    function transfer(address _to, uint256 _amount) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool);
}

contract ERC20 is IERC20 {
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    address private _owner;

    // owner -> amount
    mapping(address => uint256) private _balances;

    // owner -> spender -> amount
    mapping(address => mapping(address => uint256)) private _allowances;

    modifier onlyOwner() {
        require(msg.sender == _owner, "ERC20: Not owner");
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _owner = msg.sender;
    }

    function mint(address _to, uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        require(_to != address(0), "ERC20: Invalid minting address");
        _totalSupply += _amount;
        _balances[_to] += _amount;

        emit Transfer(address(0), _to, _amount);

        return true;
    }

    function burn(address owner_, uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        require(owner_ != address(0), "ERC20: Invalid burning address");
        require(_balances[owner_] >= _amount, "ERC20: Invalid burning amount");

        _totalSupply -= _amount;
        _balances[owner_] -= _amount;

        emit Transfer(owner_, address(0), _amount);

        return true;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner_) external view returns (uint256) {
        return _balances[owner_];
    }

    function allowance(address _from, address _spender)
        external
        view
        returns (uint256)
    {
        return _allowances[_from][_spender];
    }

    function decimals() external pure returns (uint256) {
        return 18;
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        require(_balances[msg.sender] >= _amount, "ERC20: Insufficient Balance");
        require(_to != address(0), "ERC20: Invalid recipient");

        _balances[msg.sender] -= _amount;
        _balances[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);

        return true;
    }

    function approve(address _spender, uint256 _amount)
        external
        returns (bool)
    {
        require(_spender != address(0), "ERC20: Invalid Address");
        require(_balances[msg.sender] >= _amount, "ERC20: Insufficient Balance");

        _allowances[msg.sender][_spender] += _amount;

        emit Approval(msg.sender, _spender, _amount);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool) {
        require(
            _allowances[_from][msg.sender] >= _amount,
            "ERC20: Not enough allowance"
        );
        require(_to != address(0), "ERC20: Invalid recipient");
        require(_from != address(0), "ERC20: Invalid source");

        _allowances[_from][msg.sender] -= _amount;
        _balances[_to] += _amount;

        emit Transfer(_from, _to, _amount);

        return true;
    }
}
