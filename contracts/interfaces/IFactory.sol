pragma solidity >=0.5.7;
pragma experimental ABIEncoderV2;
interface IFactory {
    function initialize(
        string calldata _name,
        string calldata _symbol,
        address _minter,
        uint256 _cap,
        string calldata blob,
        address collector
    ) external returns (bool);

    function mint(address account, uint256 value) external;

    function minter() external view returns (address);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function cap() external view returns (uint256);

    function isMinter(address account) external view returns (bool);

    function isInitialized() external view returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function proposeMinter(address newMinter) external;

    function approveMinter() external;

    function createToken(
        uint256 _templateIndex,
        string[] calldata strings,
        address[] calldata addresses,
        uint256[] calldata uints,
        bytes[] calldata bytess
    ) external returns (address token);
    

    function addToERC721Registry(address ERC721address) external;

    function erc721List(address ERC721address) external returns (address);

    function erc20List(address erc20dt) external view returns(bool);
}
