pragma solidity >=0.4.21 <0.6.0;

import "./RestrictableToOwner.sol";

/**
    A way to put the contract into a critical emergency mode
    Its essentially a way to flip between a critical and a non critical mode
    Has to be controlled by an Owner or an Administrator
 */
contract CircuitBreaker is RestrictableToOwner{

    enum CircuitBreakerState {
        Emergency,     //in emergency mode
        NoEmergency, //all is normal
        RedAlert    //a warning, lowerlevel emergency mode
    }

    CircuitBreakerState private circuitBreakerState = CircuitBreakerState.NoEmergency;

    modifier notInEmergency(){require(circuitBreakerState == CircuitBreakerState.NoEmergency,"no emergency"); _;}
    modifier inEmergency(){require(circuitBreakerState != CircuitBreakerState.NoEmergency, "not in emergency"); _;}
    modifier inRedAlert(){require(circuitBreakerState == CircuitBreakerState.RedAlert, "in red alert"); _;}

    event CircuitBreakerEmergency();
    event CircuitBreakerInRedAlert();
    event CircuitBreakerEmergencyEnded();

    /// @dev put state into a level one emergency mode
    function setCirctuitBreakerToRedAlert() public notInEmergency restrictedToOwner {
        circuitBreakerState = CircuitBreakerState.RedAlert;
        emit CircuitBreakerInRedAlert();
    }

    /// @dev put state out of emergency mode
    function setCircuitBreakerEmergencyFinished() public inEmergency restrictedToOwner {
        circuitBreakerState = CircuitBreakerState.NoEmergency;
        emit CircuitBreakerEmergencyEnded();
    }

    /// @dev put state into a critical mode
    function setCircuitBreakerToStopped() public restrictedToOwner {
        circuitBreakerState = CircuitBreakerState.Emergency;
        emit CircuitBreakerEmergency();
    }
}
