// Sources flattened with hardhat v2.12.4 https://hardhat.org

// File @axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol@v3.2.0

// SPDX-License-Identifier: MIT

import "https://github.com/PureStake/moonbeam/blob/master/precompiles/randomness/Randomness.sol";
import {RandomnessConsumer} from "https://github.com/PureStake/moonbeam/blob/master/precompiles/randomness/RandomnessConsumer.sol";

pragma solidity ^0.8.0;

interface IAxelarGateway {
    /**********\
    |* Errors *|
    \**********/

    error NotSelf();
    error NotProxy();
    error InvalidCodeHash();
    error SetupFailed();
    error InvalidAuthModule();
    error InvalidTokenDeployer();
    error InvalidAmount();
    error InvalidChainId();
    error InvalidCommands();
    error TokenDoesNotExist(string symbol);
    error TokenAlreadyExists(string symbol);
    error TokenDeployFailed(string symbol);
    error TokenContractDoesNotExist(address token);
    error BurnFailed(string symbol);
    error MintFailed(string symbol);
    error InvalidSetMintLimitsParams();
    error ExceedMintLimit(string symbol);

    /**********\
    |* Events *|
    \**********/

    event TokenSent(
        address indexed sender,
        string destinationChain,
        string destinationAddress,
        string symbol,
        uint256 amount
    );

    event ContractCall(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload
    );

    event ContractCallWithToken(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload,
        string symbol,
        uint256 amount
    );

    event Executed(bytes32 indexed commandId);

    event TokenDeployed(string symbol, address tokenAddresses);

    event ContractCallApproved(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event ContractCallApprovedWithMint(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event TokenMintLimitUpdated(string symbol, uint256 limit);

    event OperatorshipTransferred(bytes newOperatorsData);

    event Upgraded(address indexed implementation);

    /********************\
    |* Public Functions *|
    \********************/

    function sendToken(
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata symbol,
        uint256 amount
    ) external;

    function callContract(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload
    ) external;

    function callContractWithToken(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount
    ) external;

    function isContractCallApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash
    ) external view returns (bool);

    function isContractCallAndMintApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external view returns (bool);

    function validateContractCall(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash
    ) external returns (bool);

    function validateContractCallAndMint(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external returns (bool);

    /***********\
    |* Getters *|
    \***********/

    function authModule() external view returns (address);

    function tokenDeployer() external view returns (address);

    function tokenMintLimit(string memory symbol) external view returns (uint256);

    function tokenMintAmount(string memory symbol) external view returns (uint256);

    function allTokensFrozen() external view returns (bool);

    function implementation() external view returns (address);

    function tokenAddresses(string memory symbol) external view returns (address);

    function tokenFrozen(string memory symbol) external view returns (bool);

    function isCommandExecuted(bytes32 commandId) external view returns (bool);

    function adminEpoch() external view returns (uint256);

    function adminThreshold(uint256 epoch) external view returns (uint256);

    function admins(uint256 epoch) external view returns (address[] memory);

    /*******************\
    |* Admin Functions *|
    \*******************/

    function setTokenMintLimits(string[] calldata symbols, uint256[] calldata limits) external;

    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata setupParams
    ) external;

    /**********************\
    |* External Functions *|
    \**********************/

    function setup(bytes calldata params) external;

    function execute(bytes calldata input) external;
}




pragma solidity ^0.8.0;

interface IAxelarExecutable {
    error InvalidAddress();
    error NotApprovedByGateway();

    function gateway() external view returns (IAxelarGateway);

    function execute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external;

    function executeWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) external;
}




pragma solidity ^0.8.0;


contract AxelarExecutable is IAxelarExecutable {
    IAxelarGateway public immutable gateway;

    constructor(address gateway_) {
        if (gateway_ == address(0)) revert InvalidAddress();

        gateway = IAxelarGateway(gateway_);
    }

    function execute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external {
        bytes32 payloadHash = keccak256(payload);

        if (!gateway.validateContractCall(commandId, sourceChain, sourceAddress, payloadHash))
            revert NotApprovedByGateway();

        _execute(sourceChain, sourceAddress, payload);
    }

    function executeWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) external {
        bytes32 payloadHash = keccak256(payload);

        if (
            !gateway.validateContractCallAndMint(
                commandId,
                sourceChain,
                sourceAddress,
                payloadHash,
                tokenSymbol,
                amount
            )
        ) revert NotApprovedByGateway();

        _executeWithToken(sourceChain, sourceAddress, payload, tokenSymbol, amount);
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal virtual {}

    function _executeWithToken(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal virtual {}
}




pragma solidity ^0.8.0;

// This should be owned by the microservice that is paying for gas.
interface IAxelarGasService {
    error NothingReceived();
    error InvalidAddress();
    error NotCollector();
    error InvalidAmounts();

    event GasPaidForContractCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasPaidForContractCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForContractCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForContractCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasPaidForExpressCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForExpressCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasAdded(
        bytes32 indexed txHash,
        uint256 indexed logIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasAdded(bytes32 indexed txHash, uint256 indexed logIndex, uint256 gasFeeAmount, address refundAddress);

    event ExpressGasAdded(
        bytes32 indexed txHash,
        uint256 indexed logIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeExpressGasAdded(
        bytes32 indexed txHash,
        uint256 indexed logIndex,
        uint256 gasFeeAmount,
        address refundAddress
    );

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payNativeGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable;

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payNativeGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable;

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payGasForExpressCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payNativeGasForExpressCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable;

    function addGas(
        bytes32 txHash,
        uint256 txIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    function addNativeGas(
        bytes32 txHash,
        uint256 logIndex,
        address refundAddress
    ) external payable;

    function addExpressGas(
        bytes32 txHash,
        uint256 txIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    function addNativeExpressGas(
        bytes32 txHash,
        uint256 logIndex,
        address refundAddress
    ) external payable;

    function collectFees(
        address payable receiver,
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external;

    function refund(
        address payable receiver,
        address token,
        uint256 amount
    ) external;

    function gasCollector() external returns (address);
}




pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    error InvalidAccount();

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity 0.8.18;




contract ExecutableVRF is AxelarExecutable , RandomnessConsumer {
    string public value;
    string public sourceChain;
    string public sourceAddress;
    uint256 public myVRF;
    IAxelarGasService public immutable gasService;

    constructor(address gateway_, address gasReceiver_) AxelarExecutable(gateway_) payable RandomnessConsumer() {
        gasService = IAxelarGasService(gasReceiver_);
        globalRequestCount = 0;
        jackpot = 0;
        /// Set the requestId to the maximum allowed value by the precompile (64 bits)
        requestId = 2**64 - 1;
        myVRF = 0;
    }



    // Call this function to update the value of this contract along with all its siblings'.
    function setRemoteValue(
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata value_
    ) external payable {
        bytes memory payload = abi.encode(value_);
        if (msg.value > 0) {
            gasService.payNativeGasForContractCall{ value: msg.value }(
                address(this),
                destinationChain,
                destinationAddress,
                payload,
                msg.sender
            );
        }
        gateway.callContract(destinationChain, destinationAddress, payload);
    }

    // Handles calls created by setAndSend. Updates this contract's value
    function _execute(
        string calldata sourceChain_,
        string calldata sourceAddress_,
        bytes calldata payload_
    ) internal override {
        (value) = abi.decode(payload_, (string));
        sourceChain = sourceChain_;
        sourceAddress = sourceAddress_;
    }



    function setVRF(
        string calldata destinationChain,
        string calldata destinationAddress
    ) external payable {
        bytes memory payload = abi.encode(myVRF);
        if (msg.value > 0) {
            gasService.payNativeGasForContractCall{ value: msg.value }(
                address(this),
                destinationChain,
                destinationAddress,
                payload,
                msg.sender
            );
        }
        gateway.callContract(destinationChain, destinationAddress, payload);
    }






/// @notice Smart contract to demonstrate how to use requestLocalVRFRandomWords

    /// @notice The Randomness Precompile Interface
    Randomness public randomness =
        Randomness(0x0000000000000000000000000000000000000809);

    /// @notice The lottery has requested random words and is waiting for fulfillment
    error WaitingFulfillment();

    /// @notice The lottery doesn't have enough participants to start
    error NotEnoughParticipants(uint256 value, uint256 required);

    /// @notice The lottery doesn't accept additional participants
    error TooManyParticipants(uint256 value, uint256 required);

    /// @notice There are not enough fee to start the lottery
    error NotEnoughFee(uint256 value, uint256 required);

    /// @notice The deposit given is too low
    error DepositTooLow(uint256 value, uint256 required);

    /// @notice The provided fee to participate doesn't match the required amount
    error InvalidParticipationFee(uint256 value, uint256 required);

    /// @notice Event sent when a winner is awarded

    /// @param randomWord The randomWord being used (for informative purposes)

    event Awarded(uint256 randomWord);

    /// @notice Event sent when the lottery started
    /// @param participantCount The number of participants
    /// @param jackpot The total jackpot
    /// @param requestId The pseudo-random request id
    event Started(uint256 participantCount, uint256 jackpot, uint256 requestId);

    /// @notice Event sent when the lottery ends
    /// @param participantCount The number of participants
    /// @param jackpot The total jackpot
    /// @param winnerCount The number of winners
    event Ended(uint256 participantCount, uint256 jackpot, uint256 winnerCount);

    /// @notice The status of lottery
    /// @param OpenForRegistration Participants can register to get a chance to win
    /// @param RollingNumbers The lottery has requested the random words and is waiting for them
    /// @param Expired The lottery has been rolling numbers for too long. The randomness has expired
    enum LotteryStatus {
        OpenForRegistration,
        RollingNumbers,
        Expired
    }

    /// @notice The gas limit allowed to be used for the fulfillment
    /// @dev Depends on the code that is executed and the number of words requested
    /// @dev so XXX is a safe default for this example contract. Test and adjust
    /// @dev this limit based on the size of the request and the processing of the
    /// @dev callback request in the fulfillRandomWords() function.
    /// @dev The fee paid to start the lottery needs to be sufficient to pay for the gas limit
    uint64 public FULFILLMENT_GAS_LIMIT = 100000;
    
    /// @notice The minimum fee needed to start the lottery
    /// @dev This does not guarantee that there will be enough fee to pay for the
    /// @dev gas used by the fulfillment. Ideally it should be over-estimated
    /// @dev considering possible fluctuation of the gas price.
    /// @dev Additional fee will be refunded to the caller
    uint256 public MIN_FEE = FULFILLMENT_GAS_LIMIT * 1 gwei;

    /// @notice The number of winners
    /// @dev This number corresponds to how many random words will requested
    /// @dev Cannot exceed MAX_RANDOM_WORDS
    uint8 public NUM_WINNERS = 1;

    /// @notice The number of block before the request can be fulfilled (for Local VRF randomness)
    /// @dev The MIN_VRF_BLOCKS_DELAY provides a minimum number that is safe enough for
    /// @dev games with low economical value at stake.
    /// @dev Increasing the delay reduces slightly the probability (already very low)
    /// @dev of a collator being able to predict the pseudo-random number
    uint32 public VRF_BLOCKS_DELAY = MIN_VRF_BLOCKS_DELAY;

    /// @notice The minimum number of participants to start the lottery
    uint256 public MIN_PARTICIPANTS = 1;

    /// @notice The maximum number of participants allowed to participate
    /// @dev It is important to limit the total jackpot (by limiting the number of
    /// @dev participants) to guarantee the economic incentive of a collator
    /// @dev to avoid trying to influence the pseudo-random
    /// @dev (See Randomness.sol for more details)
    uint256 public MAX_PARTICIPANTS = 20;

    /// @notice The fee needed to participate in the lottery. Will go into the jackpot
    uint256 public PARTICIPATION_FEE = 100000 gwei;

    /// @notice A string used to allow having different salt that other contracts
    bytes32 public SALT_PREFIX = "my_demo_salt_change_me";

    /// @notice global number of request done
    /// @dev This number is used as a salt to make it unique for each request
    uint256 public globalRequestCount;

    /// @notice The current request id
    uint256 public requestId;

    /// @notice The list of current participants
    address[] public participants;

    /// @notice The current amount of token at stake in the lottery
    uint256 public jackpot;

    /// @notice the owner of the contract
    address owner;

    /// @notice Which randomness source to use
    Randomness.RandomnessSource randomnessSource;


    function status() external view returns (LotteryStatus) {
        Randomness.RequestStatus requestStatus = randomness.getRequestStatus(
            requestId
        );
        if (requestStatus == Randomness.RequestStatus.DoesNotExist) {
            return LotteryStatus.OpenForRegistration;
        }
        if (
            requestStatus == Randomness.RequestStatus.Pending ||
            requestStatus == Randomness.RequestStatus.Ready
        ) {
            return LotteryStatus.RollingNumbers;
        }
        return LotteryStatus.Expired;
    }

    function startLottery() external payable  {
        /// We check we haven't started the randomness request yet
 

        uint256 fee = msg.value;
        if (fee < MIN_FEE) {
            revert NotEnoughFee(fee, MIN_FEE);
        }

        /// We verify there is enough balance on the contract to pay for the deposit.
        /// This would fail only if the deposit amount required is changed in the
        /// Randomness Precompile.
        uint256 requiredDeposit = randomness.requiredDeposit();
        if (address(this).balance < requiredDeposit) {
            revert DepositTooLow(address(this).balance,requiredDeposit);
        }

            /// Requesting NUM_WINNERS random words using Local VRF Randomness
            /// with a delay of VRF_BLOCKS_DELAY blocks
            /// Refund after fulfillment will go back to the caller of this function
            /// globalRequestCount is used as salt to be unique for each request
            requestId = randomness.requestLocalVRFRandomWords(
                msg.sender,
                fee,
                FULFILLMENT_GAS_LIMIT,
                SALT_PREFIX ^ bytes32(globalRequestCount++),
                NUM_WINNERS,
                VRF_BLOCKS_DELAY
            );
        } 


    /// @notice Allows to increase the fee associated with the request
    /// @dev This is needed if the gas price increase significantly before
    /// @dev the request is fulfilled
    function increaseRequestFee() external payable {
        randomness.increaseRequestFee(requestId, msg.value);
    }


    

    function fulfillRequest() public {
        randomness.fulfillRequest(requestId);
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        emit Awarded(randomWords[0]);
        myVRF = randomWords[0];
        requestId = 0;
    }

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

}
