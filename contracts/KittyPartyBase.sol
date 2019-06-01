pragma solidity >=0.4.21 <0.6.0;

import "./helpers/CircuitBreaker.sol";
import "./helpers/ThreeStages.sol";


// base contract for all the variants of a kitty party savings scheme
contract KittyPartyBase is CircuitBreaker, ThreeStages {

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

	event ParticipantAdded(address indexed participant);
	event WinnerChosenForCycle(address indexed winner, uint cycleNumber);
	event KittyFinished();

    /// @dev Constructor
    /// @param _amount uint amount in wei as the precise participant constribution
	constructor(uint _amount) public {
		require(_amount > 0,"set a non zero value for the kitty amount");
		require(_amount <= MAX_CONTRIBUTION, "value is capped to control risk");
		amountPerParticipant = _amount;
	}

	/// @dev fallback this will add a participant, only if they send in the correct amount, and also if
	///      the kitty party is at a particular point where participants can still be allowed in, and other conditions
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
            require(stage == Stages.NotStarted, "still at the point to add participants");

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
        atStage(Stages.NotStarted)
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

    /// @dev the address of the participant at the index, order of array is the order of adding to array
    /// @param _index offset into array
    /// @return address account of the participant
    function participantAt(uint _index) public view returns(address) {
        return participant_addresses[_index];
    }

    /// @dev in the event of an emergency, get your money out for this particular cycle
	function withdrawMyRefund() public inEmergency{
		if (participants[msg.sender].hasContributedThisCycle){
			participants[msg.sender].hasContributedThisCycle = false; //internal flag is marked false first
			msg.sender.transfer(amountPerParticipant);

			doWithdrawMyRefund();   // a chance for sub classes to cleanup in the event of an emergency
		}
	}

    /// @dev utility function to see if everyone has sent in the contribution for this cycle
	function hasEveryoneContributedThisCycle()
        public
        view
        atStage(Stages.Started)
        returns (bool)
	{
		for (uint i = 0; i<numberOfParticipants; i++){
			if (!participants[participant_addresses[i]].hasContributedThisCycle){
				return false;
			}
		}
		return true;
	}

    /// @dev can be called at any point to take out the amount that was won
	function withdrawMyWinnings() public notInEmergency{
		if ((participants[msg.sender].cycleNumberWon > 0) && !participants[msg.sender].hasWithdrawnWinnings){
			participants[msg.sender].hasWithdrawnWinnings = true;
			uint amountToTransfer = numberOfParticipants * amountPerParticipant;
			msg.sender.transfer(amountToTransfer);
		}
	}

    /// @dev called by the kitty admin to finish a cycle
	function completeCycle()
		public
		notInEmergency
		restrictedToOwner
		atStage(Stages.Started)
    {
		require(hasEveryoneContributedThisCycle(),"Everyone should have contributed by now");

		//call a descendant implementation to get the winner.
		address winner = doGetWinner();
		participants[winner].cycleNumberWon = currentCycleNumber;

        //chance for a descendant to cleanup internal state
		doCycleCompleted();

        //reset for the next  cycle
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

	/// @dev sub classes will define how the winner of the current cycle is chosen
	function doGetWinner() internal returns (address);

	/// @dev chance for subclasses to regorganize internal state on completion of a cycle
	function doCycleCompleted() internal;

	/// @dev chance to do subclass specific action for refund
	function doWithdrawMyRefund() internal;
}
