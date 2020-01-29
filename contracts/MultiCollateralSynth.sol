/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       MultiCollateralSynth.sol

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

MultiCollateralSynth synths are a subclass of Synth that allows the 
multiCollateral contract to issue and burn synths.

-----------------------------------------------------------------
*/


pragma solidity 0.4.25;

import "./Synth.sol";

contract MultiCollateralSynth is Synth {

    // MultiCollateral contract able to issue and burn synth
    address public multiCollateral;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _proxy, TokenState _tokenState, address _synthetixProxy, address _feePoolProxy,
        string _tokenName, string _tokenSymbol, address _owner, bytes32 _currencyKey, uint _totalSupply, address _multiCollateral
    )
        Synth(_proxy, _tokenState, _synthetixProxy, _feePoolProxy, _tokenName, _tokenSymbol, _owner, _currencyKey, _totalSupply)
        public
    {
        multiCollateral = _multiCollateral;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /**
     * @notice Function that allows multi Collateral to issue a certain number of synths from an account.
     * @param account Account to issue synths to
     * @param amount Number of synths
     */
    function issue(address account, uint amount)
        external
        onlyMultiCollateralOrSynthetix
    {
        super._internalIssue(account, amount);
        emitCollateralIssued(account, amount);
    }
    
    /**
     * @notice Function that allows multi Collateral to burn a certain number of synths from an account.
     * @param account Account to burn synths from
     * @param amount Number of synths
     */
    function burn(address account, uint amount)
        external
        onlyMultiCollateralOrSynthetix
    {
        super._internalBurn(account, amount);
        emitCollateralBurned(account, amount);
    }
    
    /* ========== SETTERS ========== */

    function setMultiCollateral(address _multiCollateral)
        external
        optionalProxy_onlyOwner
    {
        multiCollateral = _multiCollateral;
    }


    /* ========== MODIFIERS ========== */

    modifier onlyMultiCollateralOrSynthetix() {
        bool isSynthetix = msg.sender == address(Proxy(synthetixProxy).target());
        bool isMultiCollateral = msg.sender == multiCollateral;

        require(isMultiCollateral || isSynthetix, "Only multicollateral, Synthetix allowed");
        _;
    }

    /* ========== EVENTS ========== */
    event CollateralIssued(address indexed account, uint value);
    bytes32 constant COLLATERALISSUED_SIG = keccak256("CollateralIssued(address,uint256)");
    function emitCollateralIssued(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, COLLATERALISSUED_SIG, bytes32(account), 0, 0);
    }

    event CollateralBurned(address indexed account, uint value);
    bytes32 constant COLLATERALBURNED_SIG = keccak256("CollateralBurned(address,uint256)");
    function emitCollateralBurned(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, COLLATERALBURNED_SIG, bytes32(account), 0, 0);
    }
}
