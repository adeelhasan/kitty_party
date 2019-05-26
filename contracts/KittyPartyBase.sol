pragma solidity >=0.4.21 <0.6.0;

import "./helpers/RestrictedToOwner.sol";
import "./helpers/CircuitBreaker.sol";
import "./KittyPartyState.sol";


// base contract for all the variants of a kitty savings scheme
contract KittyPartyBase is CircuitBreaker, KittyPartyState {

	struct KittyParticipant{
		bool exists;  //whether the structure actually exists or is valid, since the default is always false
		bool hasContributedThisCycle; //has the participant sent in their contribution this cycle, resets each cycle
		uint cycleNumberWon;  //when did the participant get the distribution
		bool hasWithdrawnWinnings;  //used as a flag for the withdrawl pattern
	}

	uint public amountPerParticipant; //the amount that each participant has to put in, assigned at creation time
	uint public currentCycleNumber; //where we are in the kitty cycle
	uint constant MAX_PARTICIPANTS=20; //limit the various loops to avoid high gas usage esp. the block limits
	uint constant MAX_CONTRIBUTION = 2 ether; //an upper bound so that the total ether in the contract is limited, and risk is addressed

	mapping(address=>KittyParticipant) participants; //main mapping of addresses
	address[] participant_addresses;  //accompanying array to have a list of valid keys
	uint public numberOfParticipants; //basically the length of the participant_addresses array

	modifier isAParticipant(){
		require(participants[msg.sender].exists,"is a participant");
		_;
	}

	modifier hasContributedInCurrentCycle(){
		require(participants[msg.sender].hasContributedThisCycle,"has contributed this cycle");
		_;
	}

	modifier hasNotContributedInCurrentCycle(){
		require((participants[msg.sender].exists && !participants[msg.sender].hasContributedThisCycle),"has not contributed this cycle");
		_;
	}

	modifier hasWonACycle(){
		require((participants[msg.sender].exists && participants[msg.sender].cycleNumberWon>0),"has won a cycle");
		_;
	}

	modifier hasNotWonACycle(){
		require((participants[msg.sender].exists && participants[msg.sender].cycleNumberWon==0),"has not won a cycle");
		_;
	}

	event ParticipantAdded(address indexed _participant_address);
	event WinnerChosenForCycle(address winner, uint cycleNumber);
	event KittyFinished();

	constructor(uint _amount) public {
		require(_amount > 0,"send some value, cannot make a kitty with zero value");
		require(_amount <= MAX_CONTRIBUTION, "value is capped to control risk");
		stage = Stages.Open;
		amountPerParticipant = _amount;
	}

	function ()
        external
        payable
        notAtStage(Stages.Finished)
        notInEmergency
    {
		require(participants[msg.sender].hasContributedThisCycle != true, "has already funded this cycle");
		require(msg.value == amountPerParticipant, "the correct amount should be sent");
		require(numberOfParticipants <= MAX_PARTICIPANTS, "max participants reached, cannot take more");

		//participant does not exist, so add
		if (!participants[msg.sender].exists)
		{
			require(stage == Stages.Open, "kitty is not open for more participants to be added");

			participants[msg.sender] = KittyParticipant(true,true,0,false);
			participant_addresses.push(msg.sender);

			numberOfParticipants++;

			emit ParticipantAdded(msg.sender);
		}
		else
			participants[msg.sender].hasContributedThisCycle = true;
	}

    /// @dev this completes the setup phase of the kitty party, and progresses the state forward
	function closeParticipants()
        external
        restrictedToOwner
        atStage(Stages.Open)
    {
		nextStage();
		currentCycleNumber = 1;
	}

    /// @dev a way for a participant to check their status
	function getMyStatus() external view returns (bool, bool, uint, bool){
		KittyParticipant memory k = participants[msg.sender];
		if (k.exists)
			return (k.exists, k.hasContributedThisCycle, k.cycleNumberWon, k.hasWithdrawnWinnings);
		else
			return (false,false,0,false);
	}

    /// @dev in the event of an emergency, get your money out for this particular cycle
	function withdrawMyRefund() public inEmergency{
		if (participants[msg.sender].hasContributedThisCycle){
			participants[msg.sender].hasContributedThisCycle = false; //internal flag is marked false first
			msg.sender.transfer(amountPerParticipant);

			doWithdrawMyRefund();   // a chance for sub classes to cleanup in the event of an emergency
		}
	}

	function hasEveryoneContributedThisCycle()
        public
        view
        atStage(Stages.InProgress)
        returns (bool)
	{
		for (uint i = 0; i<numberOfParticipants; i++){
			if (!participants[participant_addresses[i]].hasContributedThisCycle){
				return false;
			}
		}
		return true;
	}

	function withdrawMyWinnings() public notInEmergency{
		if ((participants[msg.sender].cycleNumberWon > 0) && !participants[msg.sender].hasWithdrawnWinnings){
			participants[msg.sender].hasWithdrawnWinnings = true;
			uint amountToTransfer = numberOfParticipants * amountPerParticipant;
			msg.sender.transfer(amountToTransfer);
		}
	}

	function completeCycle()
		public
		notInEmergency
		restrictedToOwner
		atStage(Stages.InProgress)
    {
		require(hasEveryoneContributedThisCycle(),"Everyone should have contributed by now");

		//call a descendant implementation to get the winner.
		address winner = doGetWinner();
		participants[winner].cycleNumberWon = currentCycleNumber;

		doCycleCompleted();

		for (uint i = 0; i<numberOfParticipants; i++)
		{
			participants[participant_addresses[i]].hasContributedThisCycle = false;
		}

		emit WinnerChosenForCycle(winner, currentCycleNumber);

		//if all cycles have been called, the kittyParty is finished
		if (numberOfParticipants == currentCycleNumber){
			nextStage();
			emit KittyFinished();
		}
		else
			currentCycleNumber++;
	}

	//abstract methods
	//sub classes will define how the winner of the current cycle is chosen
	function doGetWinner() internal returns (address);

	//chance for subclasses to regorganize internal state on completion of a cycle
	function doCycleCompleted() internal;

	//chance to do subclass specific action for refund
	function doWithdrawMyRefund() internal;
}
