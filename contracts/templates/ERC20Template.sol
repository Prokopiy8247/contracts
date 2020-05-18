pragma solidity ^0.5.7;
// Copyright BigchainDB GmbH and Ocean Protocol contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

import '../fee/FeeManager.sol';
import './token/ERC20Pausable.sol';

/**
* @title ERC20Template
*  
* @dev ERC20Template is a DataToken ERC20 compliant template
*      Used by the factory contract as a bytecode reference to deploy new DataTokens.
*/
contract ERC20Template is ERC20Pausable {
    using SafeMath for uint256;
    
    bool    private initialized = false;
    string  private _name;
    string  private _symbol;
    uint256 private _cap;
    uint256 private _decimals;
    address private _minter;

    FeeManager serviceFeeManager;
    
    modifier onlyNotInitialized() {
        require(
            !initialized,
            'ERC20Template: token instance already initialized'
        );
        _;
    }
    
    modifier onlyMinter() {
        require(
            msg.sender == _minter,
            'ERC20Template: invalid minter' 
        );
        _;
    }

    /**
     * @dev constructor
     *      Called on contract deployment.  Could not be called with zero address parameters.
     * @param name refers to a template DataToken name.
     * @param symbol refers to a template DataToken symbol.
     * @param minter refers to an address that has minter rights.
     * @param feeManager refers to an address of a FeeManager contract.
     */
    constructor(
        string memory name,
        string memory symbol,
        address minter,
        uint256 cap,
        address payable feeManager

    )
        public
    {
        _initialize(
            name,
            symbol,
            minter,
            cap,
            feeManager
        );
    }
    
    /**
     * @dev initialize
     *      Called on contract initialization. Used on new DataToken instance setup.
            Calls private _initialize function. Only if contract is not initialized.
     * @param name refers to a new DataToken name.
     * @param symbol refers to a nea DataToken symbol.
     * @param minter refers to an address that has minter rights.
     * @param feeManager refers to an address of a FeeManager contract.
     */
    function initialize(
        string memory name,
        string memory symbol,
        address minter,
        uint256 cap,
        address payable feeManager
    ) 
        public
        onlyNotInitialized
    {
        _initialize(
            name,
            symbol,
            minter,
            cap,
            feeManager
        );
    }

    /**
     * @dev _initialize
     *      Private function called on contract initialization.
            No of the parameters can be a zero address. 
     * @param name refers to a new DataToken name.
     * @param symbol refers to a nea DataToken symbol.
     * @param minter refers to an address that has minter rights.
     * @param feeManager refers to an address of a FeeManager contract.
     */
    function _initialize(
        string memory name,
        string memory symbol,
        address minter,
        uint256 cap,
        address payable feeManager
    ) private {
        require(
            feeManager != address(0), 
            'ERC20Template: Invalid feeManager, address(0)'
        );
        require(
            minter != address(0), 
            'ERC20Template: Invalid minter,  address(0)'
        );
        require(
            _minter == address(0), 
            'ERC20Template: Invalid minter, access denied'
        );

        require(
            cap > 0,
            'ERC20Template: Invalid cap value'
        );
        
        _decimals = 0;
        _cap = cap;
        _name = name;
        _symbol = symbol;
        _minter = minter;
        serviceFeeManager = FeeManager(feeManager);
        initialized = true;
    }

    /**
     * @dev mint
     *      Function that takes the fee as msg.value and mints new DataTokens.
            Can be called only if the contract is not paused.
            Can be called only by the minter address.
            Msg.value should be higher than zero. 
     * @param account refers to a an address that token is going to be minted to.
     * @param value refers to amount of tokens that is going to be minted.
     */
    function mint(
        address account,
        uint256 value
    ) 
    public 
    payable 
    onlyNotPaused 
    onlyMinter 
    {
        require(
            totalSupply().add(value) <= _cap, 
            'ERC20Template: cap exceeded'
        );
        require(
            msg.value >= serviceFeeManager.calculateFee(value, _cap), 
            'ERC20Template: invalid data token minting fee'
        );
        _mint(account, value);
        address(serviceFeeManager).transfer(msg.value);
    }

    /**
     * @dev pause
     *      Function that pauses the contract.
            Can be called only if the contract is not already paused.
            Can be called only by the minter address.
     */
    function pause() public onlyNotPaused onlyMinter {
        paused = true;
    }

    /**
     * @dev unpause
     *      Function that unpauses the contract.
            Can be called only if the contract is paused.
            Can be called only by the minter address.
     */
    function unpause() public onlyPaused onlyMinter {
        paused = false;
    }

    /**
     * @dev setMinter
     *      Function that sents a new minter address.
            Can be called only if the contract is not paused.
            Can be called only by the minter address.
     * @param minter refers to a new minter address.
     */
    function setMinter(address minter) public onlyNotPaused onlyMinter {
        _minter = minter;
    }

    /**
     * @dev name
     *      Function that reads private variable name.
     * @return DataToken name.
     */
    function name() public view returns(string memory) {
        return _name;
    }

    /**
     * @dev symbol
     *      Function that reads private variable symbol.
     * @return DataToken symbol.
     */
    function symbol() public view returns(string memory) {
        return _symbol;
    }

    /**
     * @dev decimals
     *      Function that reads private variable decimals.
     * @return DataToken decimals.
     */
    function decimals() public view returns(uint256) {
        return _decimals;
    }

    /**
     * @dev cap
     *      Function that reads private variable cap.
     * @return DataToken cap.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev isMinter
     *      Function takes the address and checks if it is a minter address.
     * @param account refers to the address that will be checked if it is a minter address.
     * @return DataToken cap.
     */
    function isMinter(address account) public view returns(bool) {
        return (_minter == account);
    } 

    /**
     * @dev isInitialized
     *      Function checks if the contract is initialized.
     * @return true if the contract is initialized, false if it is not.
     */ 
    function isInitialized() public view returns(bool) {
        return initialized;
    }

    /**
     * @dev isPaused
     *      Function checks if the contract is paused.
     * @return true if the contract is paused, false if it is not.
     */ 
    function isPaused() public view returns(bool) {
        return paused;
    }
}